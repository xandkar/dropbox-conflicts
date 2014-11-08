Build a tree of Dropbox conflict dependencies.

As DOT, for feeding graphviz:

```
$ dropbox_conflicts -output dot ~/Dropbox | neato -T png > conflicts.png && open conflicts.png
```

or as textual, indented trees, for feeding some other arbitrary tool or just
visual inspection:

```
$ dropbox_conflicts -output trees ~/Dropbox
/home/ibnfirnas/Dropbox/Documents/broolstoryco.txt
        /home/ibnfirnas/Dropbox/Documents/broolstoryco (huayra's conflicted copy 2014-10-22).txt

/home/ibnfirnas/Dropbox/qux/.git/index
        /home/ibnfirnas/Dropbox/qux/.git/index (r3-t2's conflicted copy 2011-12-10)
        /home/ibnfirnas/Dropbox/qux/.git/index (tie-x1's conflicted copy 2012-01-02)
        /home/ibnfirnas/Dropbox/qux/.git/index (r3-t2's conflicted copy 2011-12-24)
        /home/ibnfirnas/Dropbox/qux/.git/index (tie-x1's conflicted copy 2012-01-02 (1))
        /home/ibnfirnas/Dropbox/qux/.git/index (tie-x1's conflicted copy 2012-01-01)
        /home/ibnfirnas/Dropbox/qux/.git/index (r3-t2's conflicted copy 2012-01-16)
        /home/ibnfirnas/Dropbox/qux/.git/index (tie-x1's conflicted copy 2012-01-01 (1))
        /home/ibnfirnas/Dropbox/qux/.git/index (r3-t2's conflicted copy 2012-02-26)

/home/ibnfirnas/Dropbox/foo/doc.txt
        /home/ibnfirnas/Dropbox/foo/doc (huayra's conflicted copy 2014-10-22).txt
        /home/ibnfirnas/Dropbox/foo/doc (zonda's conflicted copy 2014-10-16).txt
                /home/ibnfirnas/Dropbox/foo/doc (zonda's conflicted copy 2014-10-16) (huayra's conflicted copy 2014-10-22).txt
        /home/ibnfirnas/Dropbox/foo/doc (r3-t2's conflicted copy 2014-07-06).txt
                /home/ibnfirnas/Dropbox/foo/doc (r3-t2's conflicted copy 2014-07-06) (huayra's conflicted copy 2014-10-22).txt
                /home/ibnfirnas/Dropbox/foo/doc (r3-t2's conflicted copy 2014-07-06) (zonda's conflicted copy 2014-10-16).txt
                        /home/ibnfirnas/Dropbox/foo/doc (r3-t2's conflicted copy 2014-07-06) (zonda's conflicted copy 2014-10-16) (huayra's conflicted copy 2014-10-22).txt

/home/ibnfirnas/Dropbox/foo/data.csv
        /home/ibnfirnas/Dropbox/foo/data (zonda's conflicted copy 2014-10-16).csv
                /home/ibnfirnas/Dropbox/foo/data (zonda's conflicted copy 2014-10-16) (huayra's conflicted copy 2014-10-22).csv
        /home/ibnfirnas/Dropbox/foo/data (r3-t2's conflicted copy 2014-07-06).csv
                /home/ibnfirnas/Dropbox/foo/data (r3-t2's conflicted copy 2014-07-06) (zonda's conflicted copy 2014-10-16).csv
                        /home/ibnfirnas/Dropbox/foo/data (r3-t2's conflicted copy 2014-07-06) (zonda's conflicted copy 2014-10-16) (huayra's conflicted copy 2014-10-22).csv
                /home/ibnfirnas/Dropbox/foo/data (r3-t2's conflicted copy 2014-07-06) (huayra's conflicted copy 2014-10-22).csv
        /home/ibnfirnas/Dropbox/foo/data (huayra's conflicted copy 2014-10-22).csv

/home/ibnfirnas/Dropbox/bar/transactions.log
        /home/ibnfirnas/Dropbox/bar/transactions (huayra's conflicted copy 2014-10-22).log
        /home/ibnfirnas/Dropbox/bar/transactions (zonda's conflicted copy 2014-06-26).log
        /home/ibnfirnas/Dropbox/bar/transactions (r3-t2's conflicted copy 2014-07-06).log
        /home/ibnfirnas/Dropbox/bar/transactions (zonda's conflicted copy 2014-10-16).log
```
