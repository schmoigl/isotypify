rm -rf .quarto
rm -rf website
quarto render
scp -r website/* lschmoigl@data-science.wifo.ac.at:/home/lschmoigl/datascience/htdocs/isoline