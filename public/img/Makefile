all: book.svg book.png book-150px.png

# Book <http://openclipart.org/detail/78469>
book.svg:
	wget -cO book.svg http://openclipart.org/people/gingercoons/1281229876.svg
book.png:
	wget -cO book.png http://openclipart.org/image/800px/svg_to_png/78469/1281229876.png

book-150px.png: book.png
	convert -resize 150 book.png book-150px.png
