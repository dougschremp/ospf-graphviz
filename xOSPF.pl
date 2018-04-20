#!/usr/bin/perl  
#Take the OSPF LSDB information from a Juniper router and convert it into a Graphviz dot file for visulization.
# if you want to get fancy Omingaffle will take this as input as well.
# Someday I will add more decorations to the node information, like model, serial# and port information. 
# That might happen when I port this to python.
#
#
#
#


use Data::Dumper;
use XML::XPath;
#
#name the output of show ospf database router |display xml |save ospf.xml
#
my $xp = XML::XPath->new ("ospf.xml");
my $router;
my $ip;
my @parts;
my @type;

#Just output the Graphviz .dot format the standard output
print "digraph OSPF { \n";
print "layout=circo\n";
#print "size=\"20,20\"\n";

foreach my $router ($xp ->find('//ospf-database[lsa-type="Router"]') ->get_nodelist) 
{
    my $routerID = $router ->find('lsa-id') ->string_value;
    
    @parts=split(/\./,$routerID);
    $routerID=join("-",@parts);
    my $linkCount= $router->find('ospf-router-lsa/link-count')->string_value;
    print "\"$routerID\" [ shape= box];\n";

	foreach $stub ($router ->find('ospf-router-lsa/ospf-link[link-type-name = "PointToPoint" ]') ->get_nodelist)
	{

	    my $link = $stub->find('link-id')->string_value;
	    @parts=split(/\./,$link);
	    $link=join("-",@parts);
	    print "\"$routerID\" -> \"$link\" ;\n";
	}
	foreach $stub ($router ->find('ospf-router-lsa/ospf-link[link-type-name = "Transit" ]') ->get_nodelist)
	{

	    my $link = $stub->find('link-id')->string_value;
	    @parts=split(/\./,$link);
	    $link=join("-","DR",@parts);
#	    print "\"$routerID\" -> \"$link\" ;\n";
	}
	foreach $stub ($router ->find('ospf-router-lsa/ospf-link[link-type-name = "Stub" ]') ->get_nodelist)
	{

	    my $link = $stub->find('link-id')->string_value;
	    @parts=split(/\./,$link);
	    $link=join("-","Stub",@parts);
#	    print "\"$routerID\" -> \"$link\" ;\n";
	}

}

print "\n}\n";
