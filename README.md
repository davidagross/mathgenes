mathgenes
=========

a MATLAB script to crawl through someone's math genes online

motivation
----------

I was inspired to make `math_genes` in the Summer of 2012 when I was discussing
with my wife the Nobel laureates her geneology.  I made the simple crawler to 
dive back into the past and download her entire tree.

That particular code was a fun exercise in regexp and HTML parsing, really, but
that's all it amounted to be.  Until Cleve Moler's recent blog post [1] about
the Forsyhte Tree [2] I didn't see much use for it.  I was inspired by
Cleve's lament and call to action to revive this code.

This is how `MathGene` was born, bringing the code into 
a (slightly) cleaner, (slightly) more robust, object oriented context.
math_gene is still provided here for posterity / anyone who wants to make
improvements to the procedural version.

usage
-----

Let's use the Forsyth Tree as an example.  Currently, MathGene takes as input
the number or string node of a person on the AMS Math Geneology Project.  
Searching for George Forsythe yields 4319.  We can then use:

```
>> format short
>> g = MathGene(4319)

g = 

   MathGene of George Elmer Forsythe:

     Ph.D. Brown University 1941 UnitedStates
     Dissertation: Riesz Summabilitly Methods of Order r, for R (r) &lt; 0,  Cesaro Summability of Independent Random Variables

     2 Advisors, 18 Students
```

to automatically download his "gene".  We can look at a summary of his students:

```
>> format long
>> g

g = 

   MathGene of George Elmer Forsythe:

     Ph.D. Brown University 1941 UnitedStates
     Dissertation: Riesz Summabilitly Methods of Order r, for R (r) &lt; 0,  Cesaro Summability of Independent Random Variables

     Advisor 1: Jacob David Tamarkin
     Advisor 2: Willi K. Feller

     18 Students:

             Name |         Institution | Year | Descendents
     Eldon Hansen | Stanford University | 1960 |  1
Beresford Parlett | Stanford University | 1962 | 59
     James Ortega | Stanford University | 1962 | 25
      Betty Stone | Stanford University | 1962 |   
    Donald Fisher | Stanford University | 1962 |   
      Ramon Moore | Stanford University | 1963 |  7
     Donald Grace | Stanford University | 1964 |   
    Robert Causey | Stanford University | 1964 |   
      Cleve Moler | Stanford University | 1965 | 99
    Roger Hockney | Stanford University | 1966 |  1
 William McKeeman | Stanford University | 1966 | 71
      James Varah | Stanford University | 1967 |  6
     Paul Richman | Stanford University | 1968 |   
    Richard Brent | Stanford University | 1971 | 28
   J. Alan George | Stanford University | 1971 | 27
 David Stoutemyer | Stanford University | 1972 |   
      Shmuel Oren | Stanford University | 1972 |  1
  Michael Malcolm | Stanford University | 1973 | 36
```

whose fulle genes are not yet downloaded.  To downloaded and look at their genes:

```
>> g.downloadStudents;
Downloading Student 1 of 18
Downloading Student 2 of 18
...
Downloading Student 18 of 18
>> format short
>> g.student(9)

ans = 

   MathGene of Cleve Barry Moler:

     Ph.D. Stanford University 1965 UnitedStates
     Dissertation: Finite Difference Methods for the Eigenvalues of Laplace's Operator

     1 Advisor, 15 Students
```

We can go futher to download Forsythe's students' students, 
and students' students' students, and so on, programmatically:

```
>> g.downloadAllDescendents;
Downloading Student 1 of 18
Downloading Student 2 of 18
  Downloading Student 1 of 26
  Downloading Student 2 of 26
    Downloading Student 1 of 3
      Downloading Student 1 of 16
... ... ... ... ...
Downloading Student 18 of 18
```

Finally,

```
>> g.printDownloadedDescendents;
```

should be able to create the base (years, names, and degrees) 
at least, of an updated Forsythe Tree, reproduced in this repository.

`math_genes.m` (deprecated by `MathGene.m`)
---------------------------------------

math_genes crawls the AMS Math Genealogy Project into the past

It will crawl into the past from a given node or person and
create a list of the history starting from that node or person.

math_genes(NODENUMBER) will crawl from a node id like:

  http://www.genealogy.ams.org/id.php?id=NODENUMBER
  
This function initiates unbridled recursion in the past and should be
used with caution.

`MathGene.m`
----------

`MathGene` is a class that replaces `math_gene`. Each gene contains
a structure leading into the past and toward the present from that
gene's dissertation.

This allows for crawling through the tree in any direction and should
be a more robust data structure for larger data sets.

results
-------

At the moment, the results of crawling too deep into the past are somewhat 
meaningless, as duplicated branches cannot reconnect in the corrent 
data structure.

Crawling to the present from a moment in the past, however, yields a tree of
descendents that is appropriate for casual observation in addition historical
analysis.

Improvements will follow and are welcome.

references
----------

[1] http://blogs.mathworks.com/cleve/2013/01/07/george-forsythe/

[2] http://infolab.stanford.edu/pub/voy/museum/forsythetree.html
