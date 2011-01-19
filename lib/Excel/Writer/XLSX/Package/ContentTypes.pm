package Excel::Writer::XLSX::Package::ContentTypes;

###############################################################################
#
# Excel::Writer::XLSX::Package::ContentTypes - A class for writing the Excel
# XLS [Content_Types] file.
#
# Used in conjunction with Excel::Writer::XLSX
#
# Copyright 2000-2010, John McNamara, jmcnamara@cpan.org
#
# Documentation after __END__
#

# perltidy with the following options: -mbl=2 -pt=0 -nola

use 5.010000;
use strict;
use warnings;
use Carp;
use Excel::Writer::XLSX::Package::XMLwriter;

our @ISA     = qw(Excel::Writer::XLSX::Package::XMLwriter);
our $VERSION = '0.06';


###############################################################################
#
# Package data.
#
###############################################################################

my $app_package  = 'application/vnd.openxmlformats-package.';
my $app_document = 'application/vnd.openxmlformats-officedocument.';

our @defaults = (
    [ 'rels', $app_package . 'relationships+xml' ],
    [ 'xml',  'application/xml' ],
);

our @overrides = (
    [ '/docProps/app.xml',    $app_document . 'extended-properties+xml' ],
    [ '/docProps/core.xml',   $app_package . 'core-properties+xml' ],
    [ '/xl/styles.xml',       $app_document . 'spreadsheetml.styles+xml' ],
    [ '/xl/theme/theme1.xml', $app_document . 'theme+xml' ],
    [ '/xl/workbook.xml',     $app_document . 'spreadsheetml.sheet.main+xml' ],
);


###############################################################################
#
# Public and private API methods.
#
###############################################################################

###############################################################################
#
# new()
#
# Constructor.
#
sub new {

    my $class = shift;
    my $self  = Excel::Writer::XLSX::Package::XMLwriter->new();

    $self->{_writer}    = undef;
    $self->{_defaults}  = [@defaults];
    $self->{_overrides} = [@overrides];

    bless $self, $class;

    return $self;
}


###############################################################################
#
# _assemble_xml_file()
#
# Assemble and write the XML file.
#
sub _assemble_xml_file {

    my $self = shift;

    return unless $self->{_writer};

    $self->_write_xml_declaration;
    $self->_write_types();
    $self->_write_defaults();
    $self->_write_overrides();

    $self->{_writer}->endTag( 'Types' );

    # Close the XM writer object and filehandle.
    $self->{_writer}->end();
    $self->{_writer}->getOutput()->close();
}


###############################################################################
#
# _add_default()
#
# Add elements to the ContentTypes defaults.
#
sub _add_default {

    my $self         = shift;
    my $part_name    = shift;
    my $content_type = shift;

    push @{ $self->{_defaults} }, [ $part_name, $content_type ];

}


###############################################################################
#
# _add_override()
#
# Add elements to the ContentTypes overrides.
#
sub _add_override {

    my $self         = shift;
    my $part_name    = shift;
    my $content_type = shift;

    push @{ $self->{_overrides} }, [ $part_name, $content_type ];

}


###############################################################################
#
# _add_sheet_name()
#
# Add the name of a worksheet to the ContentTypes overrides.
#
sub _add_sheet_name {

    my $self       = shift;
    my $sheet_name = shift;

    $sheet_name = "/xl/worksheets/$sheet_name.xml";

    $self->_add_override( $sheet_name,
        $app_document . 'spreadsheetml.worksheet+xml' );
}


###############################################################################
#
# _Add_shared_strings()
#
# Add the sharedStrings link to the ContentTypes overrides.
#
sub _add_shared_strings {

    my $self = shift;

    $self->_add_override( '/xl/sharedStrings.xml',
        $app_document . 'spreadsheetml.sharedStrings+xml' );
}


###############################################################################
#
# _add_calc_chain()
#
# Add the calcChain link to the ContentTypes overrides.
#
sub _add_calc_chain {

    my $self = shift;

    $self->_add_override( '/xl/calcChain.xml',
        $app_document . 'spreadsheetml.calcChain+xml' );
}


###############################################################################
#
# Internal methods.
#
###############################################################################


###############################################################################
#
# _write_defaults()
#
# Write out all of the <Default> types.
#
sub _write_defaults {

    my $self = shift;

    for my $aref ( @{ $self->{_defaults} } ) {
        #<<<
        $self->{_writer}->emptyTag(
            'Default',
            'Extension',   $aref->[0],
            'ContentType', $aref->[1] );
        #>>>
    }
}


###############################################################################
#
# _write_overrides()
#
# Write out all of the <Override> types.
#
sub _write_overrides {

    my $self = shift;

    for my $aref ( @{ $self->{_overrides} } ) {
        #<<<
        $self->{_writer}->emptyTag(
            'Override',
            'PartName',    $aref->[0],
            'ContentType', $aref->[1] );
        #>>>
    }
}


###############################################################################
#
# XML writing methods.
#
###############################################################################


###############################################################################
#
# _write_types()
#
# Write the <Types> element.
#
sub _write_types {

    my $self  = shift;
    my $xmlns = 'http://schemas.openxmlformats.org/package/2006/content-types';

    my @attributes = ( 'xmlns' => $xmlns, );

    $self->{_writer}->startTag( 'Types', @attributes );
}

###############################################################################
#
# _write_default()
#
# Write the <Default> element.
#
sub _write_default {

    my $self         = shift;
    my $extension    = shift;
    my $content_type = shift;

    my @attributes = (
        'Extension'   => $extension,
        'ContentType' => $content_type,
    );

    $self->{_writer}->emptyTag( 'Default', @attributes );
}


###############################################################################
#
# _write_override()
#
# Write the <Override> element.
#
sub _write_override {

    my $self         = shift;
    my $part_name    = shift;
    my $content_type = shift;
    my $writer       = $self->{_writer};

    my @attributes = (
        'PartName'    => $part_name,
        'ContentType' => $content_type,
    );

    $self->{_writer}->emptyTag( 'Override', @attributes );
}


1;


__END__

=pod

=head1 NAME

Excel::Writer::XLSX::Package::ContentTypes - A class for writing the Excel XLSX [Content_Types] file.

=head1 SYNOPSIS

See the documentation for L<Excel::Writer::XLSX>.

=head1 DESCRIPTION

This module is used in conjunction with L<Excel::Writer::XLSX>.

=head1 AUTHOR

John McNamara jmcnamara@cpan.org

=head1 COPYRIGHT

� MM-MMXI, John McNamara.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as Perl itself.

=head1 LICENSE

Either the Perl Artistic Licence L<http://dev.perl.org/licenses/artistic.html> or the GPL L<http://www.opensource.org/licenses/gpl-license.php>.

=head1 DISCLAIMER OF WARRANTY

See the documentation for L<Excel::Writer::XLSX>.

=cut
