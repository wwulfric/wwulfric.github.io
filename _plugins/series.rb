# Builds the series pages from _data/series.yml and links each post to its series.
module Jekyll
  class SeriesPage < Page
    def initialize(site, base, series)
      @site = site
      @base = base
      @dir = File.join('series', series['slug'])
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'series.html')
      data['title'] = series['title']
      data['description'] = series['summary']
      data['series'] = series
    end
  end

  class SeriesGenerator < Generator
    safe true
    # Runs after PostMetaGenerator so fallback descriptions are available
    priority :normal

    def generate(site)
      posts = site.posts.docs.to_h { |post| [post.basename_without_ext, post] }

      Array(site.data['series']).each do |series|
        items = series['posts'].map do |name|
          posts.fetch(name) { raise "series #{series['slug']}: post not found: #{name}" }
        end
        series['items'] = items.map { |post| summary_of(post) }
        items.each_with_index { |post, index| link_post(post, series, index, items) }
        site.pages << SeriesPage.new(site, site.source, series)
      end
    end

    private

    def summary_of(post)
      { 'title' => post.data['title'], 'url' => post.url, 'description' => post.data['description'] }
    end

    def link_post(post, series, index, items)
      post.data['series_info'] = {
        'title' => series['title'],
        'url' => "/series/#{series['slug']}/",
        'index' => index + 1,
        'total' => items.size,
        'previous' => index.positive? ? summary_of(items[index - 1]) : nil,
        'next' => items[index + 1] && summary_of(items[index + 1])
      }
    end
  end
end
