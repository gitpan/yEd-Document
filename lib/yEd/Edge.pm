package yEd::Edge;

use strict;
use yEd::PropertyBasedObject;
use yEd::Label::EdgeLabel;
use XML::LibXML;
use Carp;

=head1 NAME

yEd::Edge - Base class for Edges

=head1 DESCRIPTION

This is the base class for Edges. 
It may not be instanciated, instead use one of the specialized types as described in the SUPPORTED FEATURES section.

=head1 SUPPORTED FEATURES

All Edge types are supported, these are:

=over 4
    
=item *
    
L<yEd::Edge::ArcEdge>                                                                                                                                                                                                

=item *
    
L<yEd::Edge::BezierEdge>                                                                                                                                                                                             

=item *
    
L<yEd::Edge::GenericEdge>                                                                                                                                                                                            

=item *
    
L<yEd::Edge::PolyLineEdge>                                                                                                                                                                                           

=item *
    
L<yEd::Edge::QuadCurveEdge>                                                                                                                                                                                          

=item *
    
L<yEd::Edge::SplineEdge>

=back

The following features are currently not supported:

=over 4

=item *

Adding meta data to Edges or edit the present ones (e.g. URL, description)

=back

All other basic features of Edges (yEd Version 3.13) are supported.

Support beyond yEd:

=over 4
    
=item *
    
You may specify waypoints to be relative to previous waypoints / source Node (see relativeWaypoints property)

=item *

You may add multiple Labels to a single Edge (yEd will handle it properly)

=back

=head1 PROPERTIES

=head2 id

This property is read only and returns the Edge's ID.

=head2 source

Type: yEd::Node

Default: ... must be provided at constructor

The source Node reference.

=head2 target

Type: yEd::Node

Default: ... must be provided at constructor

The target Node reference.

=head2 sx

Type: float

Default: 0

The x value for Edge connection to source Node (x=0 y=0 is center).

=head2 sy

Type: float

Default: 0

The y value for Edge connection to source Node (x=0 y=0 is center).

=head2 tx

Type: float

Default: 0

The x value for Edge connection to target Node (x=0 y=0 is center).

=head2 ty

Type: float

Default: 0

The y value for Edge connection to target Node (x=0 y=0 is center).

=head2 lineColor

Type: '#0000fa' (rgb) or '#000000cc' (rgb + transparency) java.awt.Color hex form or 'none'

Default: '#000000'

The line color.

=head2 lineType

Type: descrete values ( line | dotted | dashed | dashed_dotted )

Default: 'line'

The line type.

=head2 lineWidth

Type: ufloat

Default: 1

The line width.

=head2 sArrow

Type: descrete values ( standard | delta | white_delta | diamond | white_diamond | short | plain | concave | convex | circle | transparent_circle | dash | skewed_dash | t_shape | crows_foot_one_mandatory | crows_foot_many_mandatory | crows_foot_one_optional | crows_foot_many_optional | crows_foot_one | crows_foot_many | crows_foot_optional | none )

Default: 'none'

The arrow on source side of the Edge.

=head2 tArrow

Type: descrete values ( standard | delta | white_delta | diamond | white_diamond | short | plain | concave | convex | circle | transparent_circle | dash | skewed_dash | t_shape | crows_foot_one_mandatory | crows_foot_many_mandatory | crows_foot_one_optional | crows_foot_many_optional | crows_foot_one | crows_foot_many | crows_foot_optional | none )

Default: 'none'

The arrow on target side of the Edge.

=head2 relativeWaypoints

Type: bool

Default: false

If set to true the x and y coords of added waypoints are not considered to be absolute coords, but they will be relative to the previous waypoint.
First waypoint will be relative to the source Node's coords.
Note that the coords of a Node indicate its upper left corner, not the center, while the default anchor point of Edges is the center of a Node and is described as being (0,0) in the Node's local coordinate system.
However the first (relative) waypoint WILL be calculated from the source's center modified by the anchor point by this package, so you don't have to care for such inconsistency here. 

=head1 SUBROUTINES/METHODS

=head2 new

Creates a new instance of the corresponding Edge type.

An ID must be provided as first parameter.
This value may be any string or number but must be unique among the whole L<yEd::Document>.
If you don't want to bother with IDs use the addNewEdge function of L<yEd::Document> instead, it will take care of the IDs.

Second and third parameter must be references to yEd::Node type instances, which are the Edge's source and target Nodes (in this order).

Further parameters to set properties are optional (property => value, ...).

=cut

sub new {
    confess 'you may not instantiate a yEd::Edge base class object';
}

=head2 copy

Creates a copy of this Edge and returns it.

Also copies all attached Labels and waypoints, so unless 'relativeWaypoints' was set you will most likely want to call clearWaypoints() on the copy.

An ID must be given as first parameter as described in the Edge class constructor, it will be applied to the copy.

Second and third parameter must be references to yEd::Node type instances, which are the copy's source and target Nodes (in this order).

You may optionally specify properties in the form 'property => value, ...' to change these properties for the returned copy.

=cut

sub copy {
    my ($self, $id, $s, $t, @p) = @_;
    my $ref = ref $self;
    my $o = $ref->new($id, $s, $t);
    $o->setProperties($self->getProperties());
    $o->setProperties(@p, 'source' => $s, 'target' => $t);
    foreach my $l ($self->labels()) {
        $o->addLabel($l->copy());
    }
    foreach my $wp ($self->waypoints()) {
        $o->addWaypoint(@{$wp}); 
    }
    return $o;
}

sub _init {
    my ($self, $id, $source, $target, @properties) = @_;
    confess 'edge id missing for edge creation' unless (defined $id);
    confess 'provide a source and target node for edge creation' unless (defined $source and defined $target);
    $self->{'properties'}{'id'} = $id;
    $self->{'datakeys'} = [ 'd8', 'd9' ];
    $self->{'rootkey'} = 'd10';
    $self->source($source);
    $self->target($target);
    # defaults
    $self->sx(0);
    $self->sy(0);
    $self->tx(0);
    $self->ty(0);
    $self->lineColor('#000000');
    $self->lineType('line');
    $self->lineWidth(1);
    $self->sArrow('none');
    $self->tArrow('none');
    $self->relativeWaypoints(0);
    $self->clearWaypoints();
    $self->clearLabels();
    # user values
    $self->setProperties(@properties);
    return $self;
}

# edge
sub id {
    return _PROPERTY('ro', @_);
}
sub source {
    my ($self, $value) = @_;
    my $key = 'source';
    if (defined $value) {
        confess "value must be a yEd::Node (or one of its subtypes) (given value: $value)" unless ($value->isa('yEd::Node'));
        $self->{'properties'}{$key}->_deregisterEdge($self) if (defined $self->{'properties'}{$key});
        $self->{'properties'}{$key} = $value;
        $self->{'properties'}{$key}->_registerEdge($self);
        return;
    } else {
        return $self->{'properties'}{$key};
    }
}
sub target {
    my ($self, $value) = @_;
    my $key = 'target';
    if (defined $value) {
        confess "value must be a yEd::Node (or one of its subtypes) (given value: $value)" unless ($value->isa('yEd::Node'));
        $self->{'properties'}{$key}->_deregisterEdge($self) if (defined $self->{'properties'}{$key});
        $self->{'properties'}{$key} = $value;
        $self->{'properties'}{$key}->_registerEdge($self);
        return;
    } else {
        return $self->{'properties'}{$key};
    }
}
sub _deregisterAll {
    my $self = shift;
    $self->source()->_deregisterEdge($self);
    $self->target()->_deregisterEdge($self);
}

=head2 getNodes

Returns an array of all Nodes (as references) connected to this Edge (This will always be 1 or 2 elements).

=cut

sub getNodes {
    my $self = shift;
    my @nodes;
    push @nodes, $self->source();
    push @nodes, $self->target() unless $self->source() == $self->target();
    return @nodes;
}

# Path
sub sx {
    return _PROPERTY($match{'float'}, @_);
} 
sub sy {
    return _PROPERTY($match{'float'}, @_);
} 
sub tx {
    return _PROPERTY($match{'float'}, @_);
} 
sub ty {
    return _PROPERTY($match{'float'}, @_);
} 

sub relativeWaypoints {
    return _PROPERTY('bool', @_);
} 

=head2 addWaypoint

Takes 2 parameters, a x and y coordinate for the waypoint.
The waypoint is added at the end of the list.
Waypoint order is interpreted as: first to last = source to target.

Note that source and target is not provided as waypoints, neither do the properties sx,sy,tx,ty describe waypoints.
Waypoints describe anchor mid-points for an Edge and are absolute by default.
However you can have them interpreted as being relative by using the 'relativeWaypoints' property.

=cut

sub addWaypoint {
    my ($self, @coords) = @_;
    confess "waypoints have to be added as one pair of x,y coords : addWaypoint(x,y)" unless (@coords == 2);
    confess "waypoint coords must be floatingpoint values" unless ($coords[0] =~ m/$match{'float'}/ and $coords[1] =~ m/$match{'float'}/);
    push @{$self->{'waypoints'}}, \@coords;
    return;
}

=head2 waypoints

Acts as a getter with no parameters provided and returns an array of all Waypoints attached to this Edge.

If an array of coordinates is provided (where each coordinate is an array of 2 elements (x,y)), this Edge's waypoints are replaced by the given ones.

=cut

sub waypoints {
    my ($self, @wps) = @_;
    if (@wps) {
        foreach my $wp (@wps) {
            confess "waypoint array has to consist of 2-element arrayrefs, which represent x,y coords" unless (ref($wp) eq 'ARRAY' and @{$wp} == 2);
            confess "waypoint coords must be floatingpoint values (bad pair: (@{$wp}))" unless ($wp->[0] =~ m/$match{'float'}/ and $wp->[1] =~ m/$match{'float'}/);
        } 
        $self->{'waypoints'} = \@wps;
        return;
    } else {
        return @{$self->{'waypoints'}};
    }
}

=head2 clearWaypoints

Removes all waypoints from this edge.

=cut

sub clearWaypoints {
    $_[0]->{'waypoints'} = [];
    return;
}

# Labels

=head2 addNewLabel

Takes a value for the text property of Labels followed by optional Label properties ('property' => 'value', ...) and creates and adds a new Label from it.

Returns a ref to the Label object.

=cut

sub addNewLabel {
    my $self = shift;
    my $label = yEd::Label::EdgeLabel->new(@_);
    $self->addLabel($label);
    return $label;
}

=head2 addLabel

Takes yEd::Label::EdgeLabel object and adds it.

=cut

sub addLabel {
    my ($self, $label) = @_;
    confess "only yEd::Label::EdgeLabel's can be added" unless ($label->isa('yEd::Label::EdgeLabel'));
    push @{$self->{'labels'}}, $label;
    return;
}

=head2 labels

Acts as a getter with no parameters provided and returns an array of all Labels attached to this Edge.

If an array of yEd::Label::EdgeLabel objects is provided, this Edge's Labels are replaced by the given Labels.

=cut

sub labels {
    my ($self, @labels) = @_;
    if (@labels) {
        foreach my $label (@labels) {
            confess "only yEd::Label::EdgeLabel's can be added" unless ($label->isa('yEd::Label::EdgeLabel'));
        }
        $self->{'labels'} = \@labels;
        return;
    } else {
        return @{$self->{'labels'}};
    }
}

=head2 clearLabels

Removes all Labels from this Edge.

=cut

sub clearLabels {
    $_[0]->{'labels'} = [];
    return;
}

=head2 getLabelsByProperties

Takes arguments of the form 'property1 => value, property2 => value2, ...'.

Returns a list of all Labels that matches the given filter.

=cut

sub getLabelsByProperties {
    my ($self, @properties) = @_;
    my @labels;
    foreach my $label ($self->labels()) {
        push @labels, $label if $label->hasProperties(@properties);
    }
    return @labels;
}

# LineStyle
sub lineColor {
    return _PROPERTY($match{'color'}, @_);
} 
sub lineType {
    return _PROPERTY($match{'linetype'}, @_);
} 
sub lineWidth {
    return _PROPERTY($match{'ufloat'}, @_);
} 

# Arrows
sub sArrow {
    return _PROPERTY($match{'arrowtype'}, @_);
} 
sub tArrow {
    return _PROPERTY($match{'arrowtype'}, @_);
} 

sub _build {
    my $self = shift;
    my $node = $self->_createEdgeNode();
    my $root = $self->_addRootNode($node);
    my $type = $self->_addTypeNode($root);
    $self->_addPathNode($type);
    $self->_addLineStyleNode($type);
    $self->_addArrowsNode($type);
    $self->_addLabelsNode($type);
    $self->_addAdditionalNodes($type);
    return $node;
}
sub _createEdgeNode {
    my $self = shift;
    my $node = XML::LibXML::Element->new('edge');
    $node->setAttribute('id', $self->id());
    $node->setAttribute('source', $self->source()->id());
    $node->setAttribute('target', $self->target()->id());
    foreach my $dk (@{$self->{'datakeys'}}) {
        $node->addNewChild('', 'data')->setAttribute('key', $dk);
    }
    return $node;
}
sub _addRootNode {
    my ($self, $node) = @_;
    my $root = $node->addNewChild('', 'data');
    $root->setAttribute('key', $self->{'rootkey'});
    return $root;
}
sub _addTypeNode {
    # add type node here and return it (e.g. <y:ArcEdge>)
    confess 'you may not build a yEd::Edge base class object, override this method in a specialized subclass';    
}
sub _addPathNode {
    my ($self, $node) = @_;
    my $path = $node->addNewChild('', 'y:Path');
    $path->setAttribute('sx', $self->sx());
    $path->setAttribute('sy', $self->sy());
    $path->setAttribute('tx', $self->tx());
    $path->setAttribute('ty', $self->ty());
    my @prev = $self->source()->absCenter();
    $prev[0] += $self->sx(); # <-calculated absolute coords for the source anchor
    $prev[1] += $self->sy(); # <-'
    foreach my $coords ($self->waypoints()) {
        my $x = $coords->[0];
        my $y = $coords->[1];
        if ($self->relativeWaypoints()) {
            $x += $prev[0];
            $y += $prev[1];
            $prev[0] = $x;
            $prev[1] = $y;
        }
        my $wp = $path->addNewChild('', 'y:Point');
        $wp->setAttribute('x', $x);
        $wp->setAttribute('y', $y);
    }
}
sub _addLineStyleNode {
    my ($self, $node) = @_;
    my $ls = $node->addNewChild('', 'y:LineStyle');
    $ls->setAttribute('color', $self->lineColor() eq 'none' ? '#000000' : $self->lineColor());
    $ls->setAttribute('type', $self->lineType());
    $ls->setAttribute('width', $self->lineWidth());
}
sub _addArrowsNode {
    my ($self, $node) = @_;
    my $arrows = $node->addNewChild('', 'y:Arrows');
    $arrows->setAttribute('source', $self->sArrow());
    $arrows->setAttribute('target', $self->tArrow());
}
sub _addLabelsNode {
    my ($self, $node) = @_;
    foreach my $label ($self->labels()) {
        $node->addChild($label->_build());
    }
}
sub _addAdditionalNodes {
    # add type specific data here (e.g. <y:Arc ...)
}

=head2 setProperties getProperties hasProperties

As described at L<yEd::PropertyBasedObject>

=head1 SEE ALSO

L<yEd::Document> for further informations about the whole package

L<yEd::PropertyBasedObject> for further basic information about properties and their additional functions

The specialized Edges:

L<yEd::Edge::ArcEdge>                                                                                                                                                                                                

L<yEd::Edge::BezierEdge>                                                                                                                                                                                             

L<yEd::Edge::GenericEdge>                                                                                                                                                                                            

L<yEd::Edge::PolyLineEdge>                                                                                                                                                                                           

L<yEd::Edge::QuadCurveEdge>                                                                                                                                                                                          

L<yEd::Edge::SplineEdge>

=cut

1;
