mathgenes
=========

a MATLAB script to crawl through someone's math genes online

math_genes.m
------------

math_genes crawls the AMS Math Genealogy Project into the past

It will crawl into the past from a given node or person and
create a list of the history starting from that node or person.

math_genes(NODENUMBER) will crawl from a node id like:

  http://www.genealogy.ams.org/id.php?id=NODENUMBER

MathGene.m
----------

MathGene is a class that will soon overtake and replace math_gene.  
It allows for crawling through the tree in any direction and should
be a more robust data structure for larger data sets.

results
-------

At the moment, the results of crawling into the past are somewhat meaningless,
as duplicated branches cannot reconnect in the corrent data structure.

Improvements will follow and are welcome.
