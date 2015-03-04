package Rest::HtmlVis::Content;

use 5.006;
use strict;
use warnings FATAL => 'all';

use parent qw( Rest::HtmlVis::Key );

use YAML::Syck;

=head1 NAME

Rest::HtmlVis::Content - The great new Rest::HtmlVis::Content!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Rest::HtmlVis::Content;

    my $foo = Rest::HtmlVis::Content->new();
    ...

=cut

sub setStruct {
	my ($self, $key, $struct, $env) = @_;
	$self->{struct} = $struct;
	$self->{env} = $env;

	return 1;
}

sub getOrder {
	return 99999999999;
}

sub newRow {
	return 1;
}

sub head {
'
	<script type="text/javascript">
		$(\'#myTab a\').click(function (e) {
		  e.preventDefault();
		  $(this).tab(\'show\');
		})
	</script>
'
}

sub onload {
	'prettyPrint();'
}

sub html {
	my ($self) = @_;
	my $struct = $self->getStruct;

	### Links
	my $links = '';
	if (exists $struct->{links} && ref $struct->{links} eq 'ARRAY'){
		foreach my $link (@{$struct->{links}}) {
			$links .= '<li><a href="'.$link->{href}.'">'.$link->{href}.'</a><span> - '.$link->{name}.'</span></li>';
		}
	}

	### Content
	my $content = '';
	{
		local $Data::Dumper::Indent=1;
		local $Data::Dumper::Quotekeys=0;
		local $Data::Dumper::Terse=1;
		local $Data::Dumper::Sortkeys=1;

		$content = Dump($struct);
	}

	### Form
	my $form = {};
	if (exists $struct->{form} && ref $struct->{form} eq 'HASH'){
		$form = _formToHtml($struct);
	}

"
		<div class=\"col-lg-3\">
			<ul class=\"links\">
				$links
			</ul>
		</div>
		<div class=\"col-lg-6\">
			<pre class=\"prettyprint lang-yaml\">
$content
			</pre>
		</div>
		<div class=\"col-lg-3\" role=\"tabpanel\">

			<!-- Nav tabs -->
			<ul id=\"myTab\" class=\"nav nav-tabs nav-justified\" role=\"tablist\">
				<li role=\"presentation\" class=\"active\"><a href=\"#get\" aria-controls=\"home\" role=\"tab\" data-toggle=\"tab\">GET</a></li>
				<li role=\"presentation\"><a href=\"#post\" aria-controls=\"profile\" role=\"tab\" data-toggle=\"tab\">POST</a></li>
				<li role=\"presentation\"><a href=\"#put\" aria-controls=\"messages\" role=\"tab\" data-toggle=\"tab\">PUT</a></li>
				<li role=\"presentation\"><a href=\"#delete\" aria-controls=\"settings\" role=\"tab\" data-toggle=\"tab\">DELETE</a></li>
			</ul>

			<!-- Tab panes -->
			<div class=\"tab-content\" id=\"myTabContent\">
				<div role=\"tabpanel\" class=\"tab-pane fade in active\" id=\"get\">
					<form class=\"method-form\" method=\"GET\">
".($form->{GET}||'<div class="text-center"> Not allowed </div>')."
					</form>
				</div>
				<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"post\">
					<form class=\"method-form\" method=\"POST\" action=\"http://localhost:5000/\">
".($form->{POST}||'<div class="text-center"> Not allowed </div>')."
					</form>
				</div>
				<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"put\" action=\"/\">
					<form class=\"method-form\" method=\"PUT\">
".($form->{PUT}||'<div class="text-center"> Not allowed </div>')."
					</form>
				</div>
				<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"delete\">
					<form class=\"method-form\" method=\"DELETE\">
".($form->{DELETE}||'<div class="text-center"> Not allowed </div>')."
					</form>
				</div>
			</div>

		</div>
"
}

_formToHtml {
	my ($struct) = @_;

=old

	"<button type=\"submit\" class=\"btn btn-default\">Get</button>"

	"<textarea class=\"form-control\" id=\"exampleInputEmail1\" name=\"DATA\" placeholder=\"Text\" cols=\"2\" rows=\"10\"></textarea>
	<button type=\"submit\" class=\"btn btn-default\">Post</button>"

	"<textarea class=\"form-control\" id=\"exampleInputEmail1\" name=\"DATA\" placeholder=\"Text\" cols=\"2\" rows=\"10\"></textarea>
	<button type=\"submit\" class=\"btn btn-default\">Put</button>"

	"<button type=\"submit\" class=\"btn btn-default\">Delete</button>"

=cut

	return {}
}

=head1 AUTHOR

Vaclav Dovrtel, C<< <vaclav.dovrtel at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to github repository.

=head1 ACKNOWLEDGEMENTS

Inspired by L<https://github.com/towhans/hochschober>

=head1 REPOSITORY

L<https://github.com/vasekd/Rest-HtmlVis>

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Vaclav Dovrtel.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1; # End of Rest::HtmlVis::Content
