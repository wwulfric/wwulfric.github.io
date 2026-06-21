# Makefile - 把 images/ 下所有 .drawio 源渲染成 .png
#
# 使用方法：
#   make            渲染所有过期的 .png
#   make list       列出会被生成的产物
#   make clean      删除所有由 .drawio 生成的 .png 产物（保留源文件）
#   make FOO.png    只渲染单张
#
# 渲染参数固定为：
#   -b 16          四周留 16px 边距
#   --scale 2      2x 像素密度
#
# 注意：不使用 -e。.png 是纯产物，不嵌入 XML；编辑请始终改 .drawio 源后重 make。
# 增量构建：只有当 .drawio 源比对应 .png 新时才重新导出。

DRAWIO ?= drawio
DRAWIO_FLAGS ?= -b 16 --scale 2

# 递归找所有 .drawio 源
SOURCES := $(shell find . -type f -name '*.drawio')
TARGETS := $(SOURCES:.drawio=.png)

.PHONY: all list clean

all: $(TARGETS)

list:
	@echo "Sources:"
	@for f in $(SOURCES); do echo "  $$f"; done
	@echo "Targets:"
	@for f in $(TARGETS); do echo "  $$f"; done

clean:
	@for f in $(TARGETS); do \
		if [ -f "$$f" ]; then echo "rm $$f"; rm "$$f"; fi; \
	done

# 通用规则：foo.drawio -> foo.png
%.png: %.drawio
	$(DRAWIO) -x -f png $(DRAWIO_FLAGS) -o $@ $<
