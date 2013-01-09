mathgenes
=========

a MATLAB script to crawl through someone's math genes online

MathGene.m
----------

MathGene is a class that replaces math_gene. Each gene contains
a structure leading into the past and toward the present from that
gene's dissertation.

This allows for crawling through the tree in any direction and should
be a more robust data structure for larger data sets.

math_genes.m (deprecated)
------------

math_genes crawls the AMS Math Genealogy Project into the past

It will crawl into the past from a given node or person and
create a list of the history starting from that node or person.

math_genes(NODENUMBER) will crawl from a node id like:

  http://www.genealogy.ams.org/id.php?id=NODENUMBER
  
This function initiates unbridled recursion in the past and should be
used with caution.

results
-------

At the moment, the results of crawling too deep into the past are somewhat 
meaningless, as duplicated branches cannot reconnect in the corrent 
data structure.

Crawling to the present from a moment in the past, however, yields a tree of
descendents that is appropriate for casual observation in addition historical
analysis.

Improvements will follow and are welcome.
