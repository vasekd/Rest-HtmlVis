package Rest::HtmlVis::Content;

use 5.006;
use strict;
use warnings FATAL => 'all';

use parent qw( Rest::HtmlVis::Key );

use Plack::Request;
use YAML::Syck;

=head1 NAME

Rest::HtmlVis::Content - Return base block for keys links and form.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.08';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Rest::HtmlVis::Content;

    my $foo = Rest::HtmlVis::Content->new();
    ...

=head1 KEYS

=head2 link

Convert default strcuture of links. Each link should consists of:

=over 4

=item * href

URL of target.Can be absolute or relative.

=item * title

Name of the link.

=item * rel

Identifier of the link (type of the link)

=back

Example:

	link => [
		{
			href => '/api/test',
			title => 'Test resource',
			rel => 'api.test'
		}
	]

=head2 form

Define elements of formular for html.

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
	my $env = $self->getEnv;
	
	### Links
	my $links = '';
	if (ref $struct eq 'HASH' && exists $struct->{link} && ref $struct->{link} eq 'ARRAY'){
		foreach my $link (@{$struct->{link}}) {
			$links .= '<li><a href="'.$link->{href}.'" rel="'.$link->{rel}.'">'.$link->{href}.'</a><span> - '.$link->{title}.'</span></li>';
		}
		delete $struct->{link};
	}

	### Remove form content
	my $formStruct = delete $struct->{form} if (ref $struct eq 'HASH' && exists $struct->{form} && ref $struct->{form} eq 'HASH');

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
	if ($formStruct){
		$form = _formToHtml($formStruct);
	}elsif( exists $env->{'REST.class'} && $env->{'REST.class'}->can('GET_FORM')){
		my $req = Plack::Request->new($env);
		my $par = $req->parameters;
		$par->add('content', $content);
		$form = _formToHtml($env->{'REST.class'}->GET_FORM($env, $par));
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
".($form->{get}||'<div class="text-center"> Not allowed </div>')."
					</form>
				</div>
				<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"post\">
					<form class=\"method-form\" method=\"POST\">
".($form->{post}||'<div class="text-center"> Not allowed </div>')."
					</form>
				</div>
				<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"put\">
					<form class=\"method-form\" onSubmit=\""._getAjaxCall($self, 'PUT')."\">
".($form->{put}||'<div class="text-center"> Not allowed </div>')."
					</form>
				</div>
				<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"delete\">
					<form class=\"method-form\" onSubmit=\""._getAjaxCall($self, 'DELETE')."\">
".($form->{delete}||'<div class="text-center"> Not allowed </div>')."
					</form>
				</div>
			</div>

		</div>
"
}

sub _getAjaxCall {
	my ($self, $methodType) = @_;
	"\$.ajax({
		type: '$methodType',
		url: '".$self->getEnv()->{REQUEST_URI}."',
		success: function(data) {
			alert('Success'); 
			var newDoc = document.open('text/html', 'replace');
			newDoc.write(data);
			newDoc.close();
		},
		error: function(data) {
			alert(data.responseText);
		},
		data: \$(this).serialize()
	}); return false;"
}


my $defaultForm = {
	get => 	"<button type=\"submit\" class=\"btn btn-default\">Get</button>",
	
	post => "<label class=\"col-lg-4 control-label\">Get as</label> 
	<select name=\"format\" class=\"form-control\">
		<option>text/html</option>
	  <option>application/json</option>
	  <option selected=\"selected\">text/yaml</option>
	  <option>text/plain</option>
	</select>
	<label class=\"col-lg-4 control-label\">Post as</label> 
	<select name=\"enctype\" class=\"form-control\">
	  <option>application/json</option>
	  <option selected=\"selected\">text/yaml</option>
	  <option>text/plain</option>
	</select>
	<button type=\"submit\" class=\"btn btn-default\">Post</button>",

	put =>  "<label class=\"col-lg-4 control-label\">Get as</label> 
	<select name=\"format\" class=\"form-control\">
		<option>text/html</option>
	  <option>application/json</option>
	  <option selected=\"selected\">text/yaml</option>
	  <option>text/plain</option>
	</select>
	<label class=\"col-lg-4 control-label\">Put as</label> 
	<select name=\"enctype\" class=\"form-control\">
	  <option>application/json</option>
	  <option selected=\"selected\">text/yaml</option>
	  <option>text/plain</option>
	</select>
	<button type=\"submit\" class=\"btn btn-default\">Put</button>",

	delete => "<button type=\"submit\" class=\"btn btn-default\">Delete</button>",
};

sub _formToHtml {
	my ($struct) = @_;

	my $form = {};
	foreach my $method (keys %{$struct}) {
		$method = lc ($method);
		if (exists $struct->{$method}{params} && ref $struct->{$method}{params} eq 'ARRAY'){
			my $html = '';
			foreach my $param (@{$struct->{$method}{params}}) {
				my $type = $param->{type};
				my $name = $param->{name};
				my $description = $param->{description}||$param->{name};

				next unless $name and $type;

				if ($type eq 'text'){
					my $default = ($param->{default}||'');
					$html .= '<div class="form-group">';
					$html .= '<label>'.$description.'</label>
					<input type="text" name="'.$name.'" class="form-control" placeholder="'.$default.'"></input>';
					$html .= '</div>';
				}elsif ($type eq 'textarea'){
					my $rows = ($param->{rows}||20);
					my $cols = ($param->{cols}||3);
					my $default = ($param->{default}||'');
					$html .= '<div class="form-group">';
					$html .= '<label>'.$description.'</label>';
					$html .= '<textarea class="form-control" name="'.$name.'" rows="'.$rows.'" cols="'.$cols.'">'.$default.'</textarea>';
					$html .= '</div>';
				}elsif ($type eq 'checkbox'){
					$html .= '<div class="form-group">';
					$html .= "<label >".$description.'</label>';
						foreach my $v (@{$param->{values}}){
							my $optionName = ''; my $value = '';
							if (ref $v eq 'ARRAY'){
								($optionName, $value) = @$v;
							}else{
								$optionName = $v; $value = $v;
							}
							my $checked='';
							if(exists $param->{default} and ref $param->{default} eq 'ARRAY'){
								foreach my $d (@{$param->{default}}){
									$checked = 'checked="checked"'if ($d eq $value);
								}
							}
							$html .= "<div class='checkbox'><label><input type='checkbox' value='$value' name='$name' $checked />&nbsp;$optionName</label></div>";
						}
						$html .= '</div>';
				}elsif ($type eq 'radio'){
					$html .= '<div class="form-group">';
					$html .= "<label>".$description.'</label>';
						foreach my $v (@{$param->{values}}){
							my $optionName = ''; my $value = '';
							if (ref $v eq 'ARRAY'){
								($optionName, $value) = @$v;
							}else{
								$optionName = $v; $value = $v;
							}
							my $checked='';
							if(exists $param->{default}){
								$checked = 'checked="checked"'if ($param->{default} eq $value);
							}
							$html .= "<div class='radio'><label><input type='radio' value='$value' name='$name' $checked />$optionName</label></div>";
						}
						$html .= '</div>';
				}elsif ($type eq 'select'){
					$html .= '<div class="form-group">';
					$html .= '<label>'.$description.'</label>';
					$html .= '<select class="form-control" name="'.$name.'">';
					foreach my $v (@{$param->{values}}){
						my $name = ''; my $id = '';
						if (ref $v eq 'ARRAY'){
							($id, $name) = @$v;
						}else{
							$name = $v; $id = $v;
						}
						my $default = (defined $param->{default} && $id eq $param->{default}) ? 'selected="selected"' : '';
						$html .= '<option id="'.$id.'" '.$default.'>'.$name.'</option>';
					}
					$html .= '</select>';
					$html .= '</div>';
				}
			}
			$form->{$method} .= $html;
		}elsif(exists $struct->{$method}{default}){
			my $html = '';
			$html .= '<textarea class="form-control" name="DATA" rows="20" cols="3">'.$struct->{$method}{default}.'</textarea>';
			$form->{$method} .= $html;
		}
		$form->{$method} .= $defaultForm->{$method};
	}

	return $form;
}

=encoding utf-8

=head1 AUTHOR

Václav Dovrtěl E<lt>vaclav.dovrtel@gmail.comE<gt>

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
