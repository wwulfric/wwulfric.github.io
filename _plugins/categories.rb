module Jekyll

  class CategoryIndex < Page
    def initialize(site, base, dir, cat_value, is_tag)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      if is_tag
        cat_name = 'tag'
      else
        cat_name = 'category'
      end

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "#{cat_name}_index.html")
      self.data[cat_name] = cat_value

      cat_name_title_prefix = site.config["#{cat_name}_title_prefix"] || "#{cat_name.capitalize}: "
      self.data['title'] = "#{cat_name_title_prefix}#{cat_value}"

      # 只有一篇文章的标签页内容太薄，不让搜索引擎收录
      if is_tag && site.tags[cat_value].size == 1
        self.data['sitemap'] = false
        self.data['noindex'] = true
      end
    end
  end

  class CategoryGenerator < Generator
    safe true

    def generate(site)
      if site.layouts.key? 'category_index'
        dir = site.config['category_dir'] || 'categories'
        site.categories.keys.each do |category|
          write_category_index(site, File.join(dir, category), category, false)
        end
      end

      if site.layouts.key? 'tag_index'
        dir = site.config['tag_dir'] || 'tags'
        site.tags.keys.each do |tag|
          write_category_index(site, File.join(dir, tag), tag, true)
        end
      end

    end

    def write_category_index(site, dir, category, is_tag)
      index = CategoryIndex.new(site, site.source, dir, category, is_tag)
      site.pages << index
    end
  end

end
