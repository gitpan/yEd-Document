#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 2;

use_ok( 'yEd::Document' ) || print "Bail out!\n";
diag( "Testing yEd::Document $yEd::Document::VERSION, Perl $], $^X" );

subtest 'basic yEd::Document creation' => sub {
    plan tests => 6;


    diag( "testing basic Document creation" );
    my $d = new_ok( 'yEd::Document' );

    diag( "testing basic ShapeNode creation and adding it" );
    my $n;
    eval {
        $n = $d->addNewNode('ShapeNode');
    };
    fail('basic ShapeNode creation: ' . $@) if $@;
    isa_ok($n, 'yEd::Node::ShapeNode');
    
    diag( "testing basic GenericNode creation and adding it" );
    my $g;
    eval {
        $g = $d->addNewNode('GenericNode');
    };
    fail('basic GenericNode creation: ' . $@) if $@;
    isa_ok($g, 'yEd::Node::GenericNode');

    diag( "testing basic GenericEdge creation and adding it" );
    my $e;
    eval {
        $e = $d->addNewEdge('GenericEdge',$n,$g);
    };
    fail('basic GenericEdge creation: ' . $@) if $@;
    isa_ok($e, 'yEd::Edge::GenericEdge');

    diag( "testing basic EdgeLabel creation and adding it" );
    my $l;
    eval {
        $l = $e->addNewLabel("I'm an EdgeLabel");
    };
    fail('basic EdgeLabel creation: ' . $@) if $@;
    isa_ok($l, 'yEd::Label::EdgeLabel');

    diag( "building the Document (not saving it to disk)" );
    my $xml;
    eval {
        $xml = $d->buildDocument();
    };
    fail('building the document: ' . $@) if $@;
    ok($xml =~ m/^<\?xml version="1\.0" encoding="UTF-8" standalone="no"\?>/, 'graphml document compliant');
};
