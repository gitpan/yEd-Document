package yEd::Node::GenericNode;

use strict;
use yEd::PropertyBasedObject;
use base qw(yEd::Node);
use Carp;

=head1 NAME

yEd::Node::GenericNode - Generic node type

=head1 DESCRIPTION

This is a very generic node type. 
Its shape is defined by its 'configuration' property.
Special configurations are defined by using java style properties.
This indeed makes the Node type very generic and versatile but also cumbersome to configure as you don't have a GUI.

For configuration of these java style properties use getJavaStyle and setJavaStyle.

Make sure to have a look at L<yEd::Node>, the properties and functions described there will not be repeated here.

=head1 SUPPORTED FEATURES

The GenericNode type are the nodes defined in the following yEd groups:

=over 4
    
=item *
    
Modern Nodes
    
=item *
    
Flowchart
    
=item *
    
BPMN
    
=item *
    
Entity Relationship
    
=back

However the node types defined in BPMN are not supported, yet.

The Entity Relationship Nodes are added with no labels, you have to provide them yourself.

For basic Node type feature support and which node types are supported see L<yEd::Node>.

=head1 PROPERTIES

=head2 all properties from base class

L<yEd::Node>

=head2 configuration

Type: descrete values ( see CONFIGURATIONS section )

Default: 'com.yworks.flowchart.cloud'

The specialized type of GenericNode.

The cloud has been choosen as default because I think people may need it as basic shape even if not working on a flow chart and on the other hand it is one of the types with a rather long identifier. 

=head1 SUBROUTINES/METHODS

=head2 all functions from base class

L<yEd::Node>

=cut

 my %r = (
    'bool' => '^(?:true|false)$',
    'false' => '^false$',
 );
 # This one describes the known StyleProperties and how to handle them
 my %styleProperty = (
    'ModernNodeShadow' => {
        'class' => 'java.lang.Boolean',
        'match' => $r{'bool'},
        'default' => 'false',
        'hidevalues' => $r{'false'},
    },
    'ModernNodeRadius' => {
        'class' => 'java.lang.Double',
        'match' => $match{'ufloat'},
        'default' => '10.0',
    },
    'y.view.ShadowNodePainter.SHADOW_PAINTING' => {
        'class' => 'java.lang.Boolean',
        'match' => $r{'bool'},
        'default' => 'false',
    },
    'com.yworks.flowchart.style.orientation' => {
        'class' => 'java.lang.Byte',
        'match' => '^[01234]$',
        'default' => '0',
    },
    'doubleBorder' => {
        'class' => 'java.lang.Boolean',
        'match' => $r{'bool'},
        'default' => 'false',
        'hidevalues' => $r{'false'},
    },
 );
 # This one describes the known Configurations and which StyleProperties they support
 my %Configuration = (
    # Modern Nodes
    'BevelNode' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'BevelNode2' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'BevelNode3' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'BevelNodeWithShadow' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'ShinyPlateNode' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'ShinyPlateNode2' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'ShinyPlateNode3' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'ShinyPlateNodeWithShadow' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    # Flowchart
    'com.yworks.flowchart.start1' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.start2' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.terminator' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.process' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.predefinedProcess' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.decision' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.loopLimit' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.loopLimitEnd' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.document' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.data' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.directData' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.storedData' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.sequentialData' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.dataBase' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.internalStorage' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.manualInput' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.card' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.paperType' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.cloud' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.delay' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.display' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.manualOperation' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.preparation' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.onPageReference' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.offPageReference' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.userMessage' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.networkMessage' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.annotation' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
        'com.yworks.flowchart.style.orientation' => 1,
    },
    # Entity Relationship
    'com.yworks.entityRelationship.big_entity' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.entityRelationship.small_entity' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
        'doubleBorder' => 1,
    },
    'com.yworks.entityRelationship.relationship' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
        'doubleBorder' => 1,
    },
    'com.yworks.entityRelationship.attribute' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
        'doubleBorder' => 1,
    },
 );

my $confregex = '^(?:';
$confregex .=  join '|', keys %Configuration;
$confregex .= ')$'; 

sub new {
    my ($class, @args) = @_;
    my $self = bless {}, $class;
    return $self->_init(@args);
}

sub _init {
    my ($self, @args) = @_;
    $self->configuration('com.yworks.flowchart.cloud');
    $self->SUPER::_init(@args);
    return $self;
}

sub configuration {
    return _PROPERTY($confregex, @_);
}

=head2 setJavaStyle

Takes arguments of the form 'property1 => value, property2 => value2, ...' and sets the provided java style properties accordingly.

=cut

sub setJavaStyle {
    my $self = shift;
    confess 'properties must be supplied as key => value pairs (odd number supplied)' if(@_ % 2);
    my %props = @_;
    foreach my $key (keys %props) {
        confess "no such property: $key" unless (exists $styleProperty{$key});
        my $r = $styleProperty{$key}{'match'};
        my $v = $props{$key};
        confess "value for property $key doesn't match $r (given value: $v)" unless ($v =~ m/$r/);
        $self->{'java'}{$key} = $v;
    }
    return;
}

=head2 getJavaStyle

Takes a java style property name as parameter and returns its current value.

=cut

sub getJavaStyle {
    my ($self, $sp) = @_;
    if (exists $self->{'java'}{$sp}) {
        return $self->{'java'}{$sp};
    }
    return $styleProperty{$sp}{'default'};
}

sub _addTypeNode {
    my ($self, $node) = @_;
    my $gen = $node->addNewChild('', 'y:GenericNode');
    $gen->setAttribute('configuration', $self->configuration());
    return $gen;
}
sub _addAdditionalNodes {
    my ($self, $node) = @_;
    my $t = $self->configuration();
    my @props;
    foreach my $sp (keys %{$Configuration{$t}}) {
        if (exists $styleProperty{$sp}{'hidevalues'}) {
            push @props, $sp unless ($self->getJavaStyle($sp) =~ m/$styleProperty{$sp}{'hidevalues'}/);
        } else {
            push @props, $sp;
        }
    }
    if (@props) {
        my $styles = $node->addNewChild('', 'y:StyleProperties');
        foreach my $sp (@props) {
            my $p = $styles->addNewChild('', 'y:Property');
            $p->setAttribute('class', $styleProperty{$sp}{'class'});
            $p->setAttribute('name', $sp);
            $p->setAttribute('value', $self->getJavaStyle($sp));
        }
    }
}

=head1 CONFIGURATIONS

Known configurations and which java style properties they support are defined in the GenericNode class as:

 my %r = (
    'bool' => '^(?:true|false)$',
    'false' => '^false$',
 );
 # This one describes the known StyleProperties and how to handle them
 my %styleProperty = (
    'ModernNodeShadow' => {
        'class' => 'java.lang.Boolean',
        'match' => $r{'bool'},
        'default' => 'false',
        'hidevalues' => $r{'false'},
    },
    'ModernNodeRadius' => {
        'class' => 'java.lang.Double',
        'match' => $match{'ufloat'},
        'default' => '10.0',
    },
    'y.view.ShadowNodePainter.SHADOW_PAINTING' => {
        'class' => 'java.lang.Boolean',
        'match' => $r{'bool'},
        'default' => 'false',
    },
    'com.yworks.flowchart.style.orientation' => {
        'class' => 'java.lang.Byte',
        'match' => '^[01234]$',
        'default' => '0',
    },
    'doubleBorder' => {
        'class' => 'java.lang.Boolean',
        'match' => $r{'bool'},
        'default' => 'false',
        'hidevalues' => $r{'false'},
    },
 );
 # This one describes the known Configurations and which StyleProperties they support
 my %Configuration = (
    # Modern Nodes
    'BevelNode' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'BevelNode2' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'BevelNode3' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'BevelNodeWithShadow' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'ShinyPlateNode' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'ShinyPlateNode2' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'ShinyPlateNode3' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    'ShinyPlateNodeWithShadow' => {
        'ModernNodeRadius' => 1,
        'ModernNodeShadow' => 1,
    },
    # Flowchart
    'com.yworks.flowchart.start1' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.start2' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.terminator' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.process' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.predefinedProcess' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.decision' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.loopLimit' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.loopLimitEnd' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.document' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.data' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.directData' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.storedData' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.sequentialData' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.dataBase' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.internalStorage' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.manualInput' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.card' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.paperType' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.cloud' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.delay' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.display' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.manualOperation' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.preparation' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.onPageReference' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.offPageReference' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.userMessage' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.networkMessage' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.flowchart.annotation' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
        'com.yworks.flowchart.style.orientation' => 1,
    },
    # Entity Relationship
    'com.yworks.entityRelationship.big_entity' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
    },
    'com.yworks.entityRelationship.small_entity' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
        'doubleBorder' => 1,
    },
    'com.yworks.entityRelationship.relationship' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
        'doubleBorder' => 1,
    },
    'com.yworks.entityRelationship.attribute' => {
        'y.view.ShadowNodePainter.SHADOW_PAINTING' => 1,
        'doubleBorder' => 1,
    },
 );

=head1 SEE ALSO

L<yEd::Document> for further informations about the whole package

L<yEd::PropertyBasedObject> for further basic information about properties and their additional functions

L<yEd::Node> for information about the Node base class and which other Node types are currently supported

=cut


1;
