mathgenes
=========

a MATLAB script to crawl through someone's math genes online

usage
-----

math_genes.m crawls the AMS Math Genealogy Project into the past

It will crawl into the past from a given node or person and
create a list of the history starting from that node or person.

math_genes(NODENUMBER) will crawl from a node id like:

  http://www.genealogy.ams.org/id.php?id=NODENUMBER

math_genes(PERSON_NAME) will crawl from the first match of a person's
name in their search results.

results
-------

At the moment, the results of crawling into the past are somewhat meaningless,
as duplicated branches cannot reconnect in the corrent data structure.

Improvements will follow and are welcome.
