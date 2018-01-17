all :
	@echo Your list of sequential capital letters, or possible abbrs....
	./caps.pl Readme.md | sort | uniq
	@echo
	@echo Your list of tables/figs....
	./fig_list.pl Readme.md | sort | uniq
	@echo
	@echo Your word count of the body of the paper...
	./paper_body.pl Readme.md | wc -w
