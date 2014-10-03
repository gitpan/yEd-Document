package yEd::Document;

use 5.006;
use strict;
use warnings FATAL => 'all';
use XML::LibXML;
use Carp;
use yEd::Label::EdgeLabel;
use yEd::Label::NodeLabel;
use yEd::Edge::ArcEdge;
use yEd::Edge::BezierEdge;
use yEd::Edge::GenericEdge;
use yEd::Edge::PolyLineEdge;
use yEd::Edge::QuadCurveEdge;
use yEd::Edge::SplineEdge;
use yEd::Node::ShapeNode;
use yEd::Node::GenericNode;

=head1 NAME

yEd::Document - pure perl API to easily create yEd-loadable Documents from scratch (using XML::LibXML)

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 DEPENDENCIES

=over 4
    
=item *
    
L<XML::LibXML>

=back

=head1 INTENTION

This package is intended to offer a way to create yEd Documents from scratch using perl.

It is ment to help automating the task of creating graphical overviews of platforms, workflows, dependencies, ...

Since it doesn't support all the features of a yEd created Document you can only create Documents, loading Documents into the package is not supported, yet.

=head1 SUPPORTED FEATURES

This package and all available features have been developed and tested for yEd version 3.13.

If you find it doesn't work on another version or a specific platform, please let me know.

Object features are supported as described at 

=over 4
    
=item *
    
L<yEd::Node>
    
=item *
    
L<yEd::Edge>
    
=item *
    
L<yEd::Label>
    
=back

and its subclasses.

The Document itself supports basic templating, layers and id management.

You can also use relative coords for positioning your entities and use this feature for basic grouping.

All entities are property based and can also be selected by properties.

=head1 SYNOPSIS

This package provides a pure object oriented implementation,
so only use functions and properties of yEd::Document and the other types in the context of a blessed instance.

Minimal example (creating an empty, yEd loadable Document):

    use yEd::Document;
    # create the document
    $d = yEd::Document->new();
    # build the document
    $xmlstring = $d->buildDocument();
    # or
    $d->buildDocument('/mypath/mydocument');

Example of using relative entities and layers (ready to run):

    use strict;
    use yEd::Document;
    
    my $d = yEd::Document->new();
    # play around with these values and note that the edge will always keep its right angles :)
    my $sx = -15; # -0.5 * default width 
    my $sy = 15; # 0.5 * default height -> lower left corner of source
    my $tx = 15; # 0.5 * default width 
    my $ty = 15; # 0.5 * default height -> lower right corner of target
    my $distance = 250;
    
    # place the absolute "root" node
    my $grouproot = $d->addNewNode('ShapeNode', 'x' => 1000, 'y' => 1000);
    # place another node $distance units to its right (or left if negative)
    my $n = $d->addNewNode('ShapeNode', 'x' => $distance, 'y' => 0, 'relative' => $grouproot);
    # place an edge on both which will go 50 units down, then $distance units (modified by anchor offsets) right/left (and then up again to connect to its target)
    my $e = $d->addNewEdge('PolyLineEdge', $grouproot, $n, 'relativeWaypoints' => 1, 'sx' => $sx, 'sy' => $sy, 'tx' => $tx, 'ty' => $ty);
    $e->waypoints([0,50],[$distance - $sx + $tx,0]);
    # place a circle on top of $grouproot to make the "group movement" visible in yEd
    my $c = $d->addNewNode('ShapeNode','shape' => 'ellipse', 'layer' => 1, 'x' => 1000, 'y' => 1000);
    $d->addNewEdge('PolyLineEdge', $n, $c, 'tArrow' => 'standard', 'sArrow' => 'standard');
    # you can now move the whole "group" by modifying $grouproot's x and y values (uncomment it and watch the difference in yEd)
    #$grouproot->setProperties('x' => 778.88, 'y' => 900);
    
    $d->buildDocument('test');

Example of using templating (ready to run):

    use strict;
    use yEd::Document;
    
    my $d = yEd::Document->new();
    
    # preparing the templates
    $d->addNewLabelTemplate('headline', 'NodeLabel', 'The house of Santa Claus', 'positionModell' => 'sandwich-n', 'fontSize' => 20);
    $d->addNewNodeTemplate('housenode', 'ShapeNode', 'shape' => 'ellipse', 'fillColor' => '#0000ff');
    my $wall = $d->addNewEdgeTemplate('wall', 'GenericEdge', 'lineWidth' => 5, 'fillColor' => '#0000ff', 'tArrow' => 'standard');
    $wall->addNewLabel('This', 'positionModell' => 'three_center-scentr', 'textColor' => '#005500', 'backgroundColor' => '#cccccc');
    $d->addEdgeTemplate('roof', $wall, 'fillColor' => '#ff0000');
    
    # adding the nodes
    my $n = $d->addTemplateNode('housenode', 'y' => 300);
    my $n1 = $d->addTemplateNode('housenode');
    my $n2 = $d->addTemplateNode('housenode', 'x' => 300);
    my $n3 = $d->addTemplateNode('housenode', 'x' => 300, 'y' => 300);
    # adding a node that wasn't defined as a template
    my $n4 = $d->addNewNode('ShapeNode', 'x' => 150, 'y' => -150, 'shape' => 'triangle', 'fillColor' => '#ff0000');
    $n4->addLabel($d->getTemplateLabel('headline'));
    
    # adding the edges
    $d->addTemplateEdge('wall',$n,$n1);
    ($d->addTemplateEdge('wall',$n1,$n2)->labels())[0]->text('is');
    ($d->addTemplateEdge('wall',$n2,$n)->labels())[0]->text('the');
    ($d->addTemplateEdge('wall',$n,$n3)->labels())[0]->text('house');
    ($d->addTemplateEdge('wall',$n3,$n2)->labels())[0]->text('of');
    ($d->addTemplateEdge('roof',$n2,$n4)->labels())[0]->text('San-');
    ($d->addTemplateEdge('roof',$n4,$n1)->labels())[0]->text('ta');
    ($d->addTemplateEdge('wall',$n1,$n3)->labels())[0]->text('Claus');
    
    $d->buildDocument('santa_claus');

=head1 OBJECT IDENTIFIERS

All Nodes and Edges of a Document must have an unique ID.

If you only use the yEd::Document's addNew... functions and templating features you won't have to care for IDs.

But if you need to externally create Nodes or Edges from its classes you will have to provide the ID yourself.

In this case it is up to you to ensure unique values unless you obtain the IDs via yEd::Document's getFreeId function.

This automatically created IDs will always be positive integer values, but if you provide your own IDs you can use almost anything.

If you load and save a Document in yEd all IDs will be converted to yEd's syntax ('n0','n1',...,'e0','e1',...).

=head1 TEMPLATING

If you have to add many copies of the same modification of a Node, Edge or Label have a look at yEd::Document's template functions.

These offer the ability to save an object's configuration and return and/or add copies of it.

For Nodes and Edges added Labels will be copied along with the template.

For Nodes that are relative to other Nodes you may want to call 'relative(0)' or 'relative($newTarget)' on the copy (or provide it with the properties parameter).

For Edges all waypoints are copied along with the template, this may not be what you want unless the Edge's 'relativeWaypoints' property is set, consider calling 'clearWaypoints()' on the copy.

=head1 RELATIVE OBJECTS

A Node or Edge-waypoint by default will be absolute, this is its x and y values are directly applied to the drawing pane.

However you can change a Node to be relative to a given other Node by using the Node's 'relative' property.
In this case x and y are values that are added to the other Node's absolute position to determine the Node's position.
The other Node however may be relative to yet another Node, too.
Just make sure you don't create dependency loops. ;)

If you manually cut the relation of two Nodes by setting 'relative(0)' on the dependend Node, the provided x and y value will not be changed but only interpreted as being absolute further on.
If you want to cut the relation without changing the Node's current absolute position call '$n->x($n->absX)' and '$n->y($n->absY)' BEFORE the call to 'relative(0)'.

Note that the x and y coords of a Node refer to its upper left corner or rather the upper left corner of the Node's surrounding rectangle (e.g. for ellipse ShapeNodes).
Consider this if you do any Node positioning math in your scripts.

Edges do have such a property, too, it is called 'relativeWaypoints' but is a boolean value in contrast to Node's property.
If set to a true value any waypoints added to this Edge will be positioned relative to the previous waypoint.
The first waypoint's position will be calculated relative to the Edge's anchor point on its source Node (sx,sy). 

If you change from 'relativeWaypoints(1)' to 'relativeWaypoints(0)' there will be no conversion of the waypoint coords by default (same behavior as for Nodes).

Note that the source Node anchor point (sx,sy) is relative to the Node's center (sx = sy = 0).
This is somehow inconsistent as the Node's coords don't describe its center.
Consider this if you do any positioning math in your scripts.
However for relative waypoints you will likely have the desired bahavior by default, since first waypoint is relative to the anchor point which's absolute position is automatically computed for you by this package.

Hint: If you create "groups" with the reative feature always build your group on top of a root node that spans the whole area of the group.
If you need the Nodes to not be surrounded by a background root Node simply make it invisible (no fill color, no border).
This way you can always ask your root Node for the width and height of the whole "group" if you need these values for calculation. :)

Note that this way of "grouping" has no effect in yEd, it does only exist within the code.

=cut 

#TODO: VirtualGroupNode Type ? invisible rectangle ShapeNode that allows adding relative Nodes and autosizes itself on Node addition/removal ...

=head1 LAYERS

yEd Documents / Nodes do only support "virtual" layering which is saved to the graphml file by giving the Nodes a special order (first Node defined is drawn first).

This concept has been adopted by this package.
The layer is described as a property of each Node, named 'layer' (Edges do not support layering, they will always be drawn on top the Nodes).
Its default value is 0 which is the bottom layer.
You can define the layer of a Node as any positive integer value, where a higher value is "more in front".

Within a single layer the drawing order of Nodes is undefined, if they overlap or need a special order because of other reasons use different layers.

Like with any other property you may obtain a list of all Nodes on a specified layer by using 'getNodesByProperties' (e.g. getNodesByProperties(layer => 3)).

=head1 SUBROUTINES/METHODS

=head2 new

Creates a new instance of yEd::Document and initializes it.

=cut

sub new {
    my $self = {};
    bless $self, shift;
    $self->resetDocument();
    $self->{'dummynode'} = yEd::Node::ShapeNode->new('noid');
    return $self;
}

my %graphmlAttr = (
    'xmlns'=> 'http://graphml.graphdrawing.org/xmlns',
    'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
    'xmlns:y' => 'http://www.yworks.com/xml/graphml',
    'xmlns:yed' => 'http://www.yworks.com/xml/yed/3',
    'xsi:schemaLocation' => 'http://graphml.graphdrawing.org/xmlns http://www.yworks.com/xml/schema/graphml/1.1/ygraphml.xsd',
);
my %docKeyAttr = (
    'd0'  => { 'for' => 'graph', 'attr.type' => 'string', 'attr.name' => 'Description' },
    'd1'  => { 'for' => 'port', 'yfiles.type' => 'portgraphics' },
    'd2'  => { 'for' => 'port', 'yfiles.type' => 'portgeometry' },

    'd4'  => { 'for' => 'node', 'attr.type' => 'string', 'attr.name' => 'url' },
    'd5'  => { 'for' => 'node', 'attr.type' => 'string', 'attr.name' => 'description' },
    'd6'  => { 'for' => 'node', 'yfiles.type' => 'nodegraphics' },
    'd7'  => { 'for' => 'graphml', 'yfiles.type' => 'resources' },
    'd8'  => { 'for' => 'edge', 'attr.type' => 'string', 'attr.name' => 'url' },
    'd9'  => { 'for' => 'edge', 'attr.type' => 'string', 'attr.name' => 'description' },
    'd10' => { 'for' => 'edge', 'yfiles.type' => 'edgegraphics' },
);

=head2 resetDocument

Resets (empties) and reinitializes this Document.

Previously registered templates will be kept.

=cut

sub resetDocument {
    my $self = shift;
    $self->{'DOC'} = XML::LibXML::Document->new('1.0', 'UTF-8');
    $self->{'DOC'}->setStandalone(0);
    $self->{'ROOT'} = $self->{'DOC'}->createElement('graphml');
    foreach my $key (keys %graphmlAttr) {
        $self->{'ROOT'}->setAttribute($key => $graphmlAttr{$key});
    }
    foreach my $id (keys %docKeyAttr) {
        my $keyelement = $self->{'ROOT'}->addNewChild('', 'key');
        $keyelement->setAttribute('id' => $id);
        foreach my $key (keys %{$docKeyAttr{$id}}) {
            $keyelement->setAttribute($key => $docKeyAttr{$id}{$key});
        }
    }
    $self->{'nodes'} = {};
    $self->{'edges'} = {};    
    $self->{'lastid'} = 0;
    return;
}

=head2 buildDocument

Builds the Document and returns it as a string.

If a filename is provided (without the ending) it will additionally be written into filename.graphml . 

=cut

sub buildDocument {
    my $self = shift;
    my $filename = shift;
    my $graph = $self->{'ROOT'}->addNewChild('', 'graph');
    $graph->setAttribute('edgedefault' => 'directed');
    $graph->setAttribute('id' => 'G');
    $graph->addNewChild('', 'data')->setAttribute('key' => 'd0');
    for (my $l = 0; $l <= $self->getFrontLayer(); $l++) {
        foreach my $n ($self->getNodesByProperties('layer' => $l)) {
            if (my $n2 = $n->relative()) {
                confess "node $n2 (id: " . $n2->id() . ") as referenced by relative node $n (id: " . $n->id() . ") is not part of this document" unless ($self->hasNodeId($n2->id()));
            }
            $graph->addChild($n->_build());
        }
    }
    foreach my $e ($self->getEdges()) {
        foreach my $n ($e->getNodes()) {
            confess "node $n (id: " . $n->id() . ") as referenced by edge $e (id: " . $e->id() . ") is not part of this document" unless ($self->hasNodeId($n->id()));
        }
        $graph->addChild($e->_build());
    }
    my $datablock = $self->{'ROOT'}->addNewChild('', 'data');
    $datablock->setAttribute('key' => 'd7');
    $datablock->addNewChild('', 'y:Resources');
    $self->{'DOC'}->setDocumentElement($self->{'ROOT'});
    my $out = $self->{'DOC'}->toString();
    if ($filename) {
        $filename .= '.graphml';
        open( OUTFILE, '>', $filename ) or confess "couldn't open $filename for write access";
        print OUTFILE $out;
        close OUTFILE;
    }
    return $out;
}

=head2 getFreeId

Returns the next still free ID number, that can be used for creating new Nodes or Edges.

This is only required if you externally create new Nodes/Edges and you could also use own values as IDs (you will then have to ensure that all IDs are unique).

=cut

sub getFreeId {
    my $self = shift;
    my $id = $self->{'lastid'};
    do {
        $id++;
    } while ($self->hasNodeId($id) or $self->hasEdgeId($id));
    $self->{'lastid'} = $id;
    return $id;
}

=head2 getFrontLayer

Returns the highest layer number that is set for any Node of this Document.

=cut

sub getFrontLayer {
    my $self = shift;
    my $layer = 0;
    foreach my $node ($self->getNodes()) {
        $layer = $node->layer() if ($node->layer() > $layer);
    }
    return $layer;
}

# Templates

=head2 addNewLabelTemplate

Creates a template for Labels.

Must have parameters are: templatename (a string for accessing the template) , labeltype (Node- or EdgeLabel) , labeltext (the text for the Label)

Further parameters to set properties are optional (property => value, ...).

The template Label is returned as a reference, if you modify this reference all further copies of the template will be affected !
Copies created earlier will not be affected since they are as said copies.

=cut

sub addNewLabelTemplate {
    my ($self, $name, $type, @param) = @_;
    confess 'provide templateName, labelType, labelText, [labelProperties]' unless (defined $name and defined $type and @param);
    $type = 'yEd::Label::' . $type;
    my $o = $type->new(@param);
    return $self->addLabelTemplate($name, $o);
}

=head2 addLabelTemplate

Creates a template for Labels.

Must have parameters are: templatename (a string for accessing the template) , label (a reference to a Label object)

Further parameters to set properties are optional (property => value, ...).

The source Label will not be changed, a copy of the Label will be used as template.
If you want to modify the template after adding it use the returned reference to the copy.

=cut

sub addLabelTemplate {
    my ($self, $name, $label,@param) = @_;
    confess 'must be of type yEd::Label' unless ($label->isa('yEd::Label'));
    $self->{'labelTemplates'}{$name} = $label->copy(@param);
    return $self->{'labelTemplates'}{$name};
}

=head2 getTemplateLabel

Creates a copy of a previously created Label template and returns it.

Must have parameters are: templatename (a string for accessing the template)

Further parameters to set properties are optional (property => value, ...).

In contrast to Nodes and Edges Label templates can not be added directly because the need to be added to a Node or Edge.
So use this function to obtain a copy and do with it what ever you want.

=cut

sub getTemplateLabel {
    my ($self, $name, @params) = @_;
    confess 'provide templateName, [labelProperties]' unless (defined $name);
    confess "no such template: $name" unless (exists $self->{'labelTemplates'}{$name});
    return $self->{'labelTemplates'}{$name}->copy(@params);
}

=head2 addNewNodeTemplate

Creates a template for Nodes.

Must have parameters are: templatename (a string for accessing the template) , nodetype (Shape- or GenericNode)

Further parameters to set properties are optional (property => value, ...).

The template Node is returned as a reference, if you modify this reference all further copies of the template will be affected !
Copies created earlier will not be affected since they are as said copies.

=cut

sub addNewNodeTemplate {
    my ($self, $name, $type, @param) = @_;
    confess 'provide templateName, nodeType, [nodeProperties]' unless (defined $name and defined $type);
    $type = 'yEd::Node::' . $type;
    my $o = $type->new('noid', @param);
    return $self->addNodeTemplate($name, $o);;
}

=head2 addNodeTemplate

Creates a template for Nodes.

Must have parameters are: templatename (a string for accessing the template) , node (a reference to a Node object)

Further parameters to set properties are optional (property => value, ...).

The source Node will not be changed, a copy of the Node will be used as template.
If you want to modify the template after adding it use the returned reference to the copy.

=cut

sub addNodeTemplate {
    my ($self, $name, $node, @param) = @_;
    confess 'must be of type yEd::Node' unless ($node->isa('yEd::Node'));
    $self->{'nodeTemplates'}{$name} = $node->copy('noid', @param);
    return $self->{'nodeTemplates'}{$name};
}

=head2 getTemplateNode

Creates a copy of a previously created Node template and returns it.
    
Must have parameters are: templatename (a string for accessing the template)
    
Further parameters to set properties are optional (property => value, ...).

=cut

sub getTemplateNode {
    my ($self, $name, @params) = @_;
    confess 'provide templateName, [nodeProperties]' unless (defined $name);
    confess "no such template: $name" unless (exists $self->{'nodeTemplates'}{$name});
    return $self->{'nodeTemplates'}{$name}->copy($self->getFreeId(), @params);
}

=head2 addTemplateNode

Creates a copy of a previously created Node template, adds it to the Document and returns it.
    
Must have parameters are: templatename (a string for accessing the template)
    
Further parameters to set properties are optional (property => value, ...).

=cut

sub addTemplateNode {
    my ($self, $name, @params) = @_;
    my $o = $self->getTemplateNode($name, @params);
    $self->addNode($o);
    return $o;
}

=head2 addNewEdgeTemplate

Creates a template for Edges.

Must have parameters are: templatename (a string for accessing the template) , edgetype (one of the supported Edge class names)

Further parameters to set properties are optional (property => value, ...).

The template Edge is returned as a reference, if you modify this reference all further copies of the template will be affected !
Copies created earlier will not be affected since they are as said copies.

=cut

sub addNewEdgeTemplate {
    my ($self, $name, $type, @param) = @_;
    confess 'provide templateName, edgeType, [edgeProperties]' unless (defined $name and defined $type);
    $type = 'yEd::Edge::' . $type;
    my $o = $type->new('noid', $self->{'dummynode'}, $self->{'dummynode'}, @param);
    return $self->addEdgeTemplate($name, $o);;
}

=head2 addEdgeTemplate

Creates a template for Edges.
    
Must have parameters are: templatename (a string for accessing the template) , edge (a reference to an Edge object)
    
Further parameters to set properties are optional (property => value, ...).

The source Edge will not be changed, a copy of the Edge will be used as template.
If you want to modify the template after adding it use the returned reference to the copy.

=cut

sub addEdgeTemplate {
    my ($self, $name, $edge, @param) = @_;
    confess 'must be of type yEd::Edge' unless ($edge->isa('yEd::Edge'));
    $self->{'edgeTemplates'}{$name} = $edge->copy('noid', $self->{'dummynode'}, $self->{'dummynode'}, @param);
    return $self->{'edgeTemplates'}{$name};
}

=head2 getTemplateEdge

Creates a copy of a previously created Edge template and returns it.
    
Must have parameters are: templatename (a string for accessing the template), source, target (the new source and target yEd::Node refs for the new Edge)
    
Further parameters to set properties are optional (property => value, ...).

=cut

sub getTemplateEdge {
    my ($self, $name, $s, $t, @params) = @_;
    confess 'provide templateName, edgeSourceNode, edgeTargetNode, [edgeProperties]' unless (defined $name and defined $s and defined $t);
    confess "no such template: $name" unless (exists $self->{'edgeTemplates'}{$name});
    return $self->{'edgeTemplates'}{$name}->copy($self->getFreeId(), $s, $t, @params);
}

=head2 addTemplateEdge

Creates a copy of a previously created Edge template, adds it to the Document and returns it.
    
Must have parameters are: templatename (a string for accessing the template), source, target (the new source and target yEd::Node refs for the new Edge)
    
Further parameters to set properties are optional (property => value, ...).

=cut

sub addTemplateEdge {
    my ($self, $name, $s, $t, @params) = @_;
    my $o = $self->getTemplateEdge($name, $s, $t, @params);
    $self->addEdge($o);
    return $o;
}

# Nodes

=head2 addNewNode

Creates a new Node, adds it and returns a reference to it.

Must have parameters are: nodetype (Shape- or GenericNode)

Further parameters to set properties are optional (property => value, ...).

=cut

sub addNewNode {
    my ($self, $type, @param) = @_;
    $type = 'yEd::Node::' . $type;
    my $node = $type->new($self->getFreeId(), @param); 
    $self->addNode($node);
    return $node;
}

=head2 addNode

Takes a yEd::Node as parameter and adds it to the Document.

=cut

sub addNode {
    my ($self, $node) = @_;
    confess 'must be of type yEd::Node' unless ($node->isa('yEd::Node'));
    confess "node ids must be unique: " . $node->id() if $self->hasNodeId($node->id());
    $self->{'nodes'}{$node->id()} = $node;
    return;
}

=head2 getNodes

Returns an array of all Nodes of this Document.

=cut

sub getNodes {
    return values $_[0]->{'nodes'};
}

=head2 getNodesByProperties

Takes arguments of the form 'property1 => value, property2 => value2, ...'.

Returns a list of all Nodes that matches the given filter.

=cut

sub getNodesByProperties {
    my ($self, @properties) = @_;
    my @nodes;
    foreach my $node ($self->getNodes()) {
        push @nodes, $node if $node->hasProperties(@properties);
    }
    return @nodes;
}

=head2 hasNodeId

Takes a Node's id as parameter and returns true if it is present in this Document.

=cut

sub hasNodeId {
    my ($self, $id) = @_;
    confess 'no id provided' unless (defined $id);
    return exists $self->{'nodes'}{$id}; 
}

=head2 getNodeById

Takes an id as parameter and returns the Node with this id, if present in this Document.

=cut

sub getNodeById {
    my ($self, $id) = @_;
    confess 'no id provided' unless (defined $id);
    return $self->{'nodes'}{$id};
}

=head2 removeNode

Takes a yEd::Node as parameter and tries to remove it from this document.

All connected Edges will be removed, too.

If there are Nodes relative to the given Node, they will also be removed (and their Edges and Nodes relative to these Nodes and so on, until all dependencies are resolved) unless the second (keepRelative) parameter is true.
In this case the absolute x and y values are calculated and the relationship is cut, making the orphaned Nodes absolute. 

Example: if you call removeNode($grouproot) in the "example of using relative entities and layers" (see SYNOPSIS), only the circle will remain.
If you call removeNode($grouproot, 1) instead, only $grouproot and $e will be removed, making $n absolute at its last position.

=cut

sub removeNode {
    my ($self, $node, $keepRelative) = @_;
    confess 'no yEd::Node provided' unless (defined $node and $node->isa('yEd::Node'));
    if ($self->hasNodeId($node->id())) {
        delete $self->{'nodes'}{$node->id()};
        foreach my $e ($node->getEdges()) {
            $self->removeEdge($e);
        }
        foreach my $n ($self->getNodesByProperties('relative' => $node)) {
            if ($keepRelative) {
                $n->x($n->absX());
                $n->y($n->absY());
                $n->relative(0);
            } else {
                $self->removeNode($n);
            }
        }
    }
    return;
}

# Edges

=head2 addNewEdge

Creates a new Edge, adds it and returns a reference to it.

Must have parameters are: edgetype (one of the supported Edge class names), source, target (the source and target yEd::Node refs for the new Edge)

Further parameters to set properties are optional (property => value, ...).

=cut

sub addNewEdge {
    my ($self, $type, @param) = @_;
    $type = 'yEd::Edge::' . $type;
    my $edge = $type->new($self->getFreeId(), @param);
    $self->addEdge($edge);
    return $edge;
}

=head2 addEdge

Takes a yEd::Edge as parameter and adds it to the Document.

=cut

sub addEdge {
    my ($self, $edge) = @_;
    confess 'must be of type yEd::Edge' unless ($edge->isa('yEd::Edge'));
    confess 'edge ids must be unique: ' . $edge->id() if $self->hasEdgeId($edge->id());
    $self->{'edges'}{$edge->id()} = $edge;
    return;
}

=head2 getEdges

Returns an array of all Edges of this Document.

=cut

sub getEdges {
    return values $_[0]->{'edges'};
}

=head2 getEdgesByProperties

Takes arguments of the form 'property1 => value, property2 => value2, ...'.

Returns a list of all Edges that matches the given filter.

=cut

sub getEdgesByProperties {
    my ($self, @properties) = @_;
    my @edges;
    foreach my $edge ($self->getEdges()) {
        push @edges, $edge if $edge->hasProperties(@properties);
    }
    return @edges;
}

=head2 hasEdgeId

Takes an Edge's id as parameter and returns true if it is present in this Document.

=cut

sub hasEdgeId {
    my ($self, $id) = @_;
    confess 'no id provided' unless (defined $id);
    return exists $self->{'edges'}{$id}; 
}

=head2 getEdgeById

Takes an id as parameter and returns the Edge with this id, if present in this Document.

=cut

sub getEdgeById {
    my ($self, $id) = @_;
    confess 'no id provided' unless (defined $id);
    return $self->{'edges'}{$id};
}

=head2 removeEdge

Takes a yEd::Edge as parameter and tries to remove it from this document.

=cut

sub removeEdge {
    my ($self, $edge) = @_;
    confess 'no yEd::Edge provided' unless (defined $edge and $edge->isa('yEd::Edge'));
    if ($self->hasEdgeId($edge->id())) {
        $edge->_deregisterAll();
        delete $self->{'edges'}{$edge->id()};
    }
    return;
}

=head1 AUTHOR

Heiko Finzel, C<< <heikofinzel at googlemail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-yed-document at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=yEd-Document>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc yEd::Document

Also see perldoc of the other classes of this package.

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=yEd-Document>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/yEd-Document>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/yEd-Document>

=item * Search CPAN

L<http://search.cpan.org/dist/yEd-Document/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Heiko Finzel.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1;
