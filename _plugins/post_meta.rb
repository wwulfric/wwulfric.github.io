# Prepares data for the templates: unified tags, fallback descriptions,
# related posts and tag statistics.
module Jekyll
  Hooks.register :site, :post_read do |site|
    aliases = site.config['tag_aliases'] || {}
    site.posts.docs.each do |post|
      post.data['tags'] = Array(post.data['tags']).map { |tag| aliases.fetch(tag, tag) }.uniq
    end
  end

  class PostMetaGenerator < Generator
    safe true
    priority :high

    DESCRIPTION_LENGTH = 120
    RELATED_LIMIT = 3
    RELATED_MIN_SCORE = 1.5

    def generate(site)
      posts = site.posts.docs
      frequency = Hash.new(0)
      posts.each { |post| post.data['tags'].each { |tag| frequency[tag] += 1 } }

      posts.each do |post|
        post.data['description'] ||= fallback_description(post)
        post.data['related_items'] = related_items(post, posts, frequency)
      end

      site.data['tag_stats'] = frequency
        .map { |name, count| { 'name' => name, 'count' => count } }
        .sort_by { |tag| [-tag['count'], tag['name'].downcase] }
    end

    private

    # First real paragraph of the post, without Markdown syntax
    def fallback_description(post)
      paragraph = post.content.split(/\n\s*\n/).map(&:strip).find do |block|
        block.length >= 20 && !block.match?(/\A(#|!\[|```|~~~|\||\$\$|\{|<|---|\[\^)/)
      end
      return unless paragraph

      text = paragraph
        .gsub(/!\[[^\]]*\]\([^)]*\)/, '')
        .gsub(/\[([^\]]*)\]\([^)]*\)/, '\1')
        .gsub(/\[\^[^\]]*\]/, '')
        .gsub(/[`*_>]/, '')
        .gsub(/\s+/, ' ')
        .strip
      text.length > DESCRIPTION_LENGTH ? "#{text[0, DESCRIPTION_LENGTH]}…" : text
    end

    # Rarer shared tags count for more; ties go to the closest publication date
    def related_items(post, posts, frequency)
      scored = (posts - [post]).filter_map do |other|
        shared = post.data['tags'] & other.data['tags']
        score = shared.sum { |tag| Math.log(posts.size.to_f / frequency[tag]) }
        [score, other] if score >= RELATED_MIN_SCORE
      end
      scored
        .sort_by { |score, other| [-score, (other.date - post.date).abs] }
        .first(RELATED_LIMIT)
        .map { |_, other| { 'title' => other.data['title'], 'url' => other.url } }
    end
  end
end
