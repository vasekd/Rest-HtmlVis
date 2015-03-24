# NAME

Rest::HtmlVis - Rest API visualizer in HTML

# SYNOPSIS

Transform perl hash to html.
Each key in perl hash is transormed to the piece of html, js and css those are include in main html.

Example:

        use Rest::HtmlVis;

        my $htmlvis = Rest::HtmlVis->new({
                events => Rest::HtmlVis::Events
        });

        $htmlvis->html({

                events => [
                ],

                links => {
                        rel => 'root',
                        href => /,
                        name => Root resource
                }

                form => {
                        GET => {
                                from => {
                                        type => 'time',
                                        default => time(),
                                }
                        },
                        POST => {
                                DATA => {
                                        type => "text"
                                        temperature => 25
                                },

                        }
                }
        });

HtmlVis has default blocks that are show everytime:

- default.base

    See [Rest::HtmlVis::Base](https://metacpan.org/pod/Rest::HtmlVis::Base).

- default.content

    See [Rest::HtmlVis::Content](https://metacpan.org/pod/Rest::HtmlVis::Content).

These blocks can be rewrite when the base or content key is set in constructor params.

# SUBROUTINES/METHODS

## new( params )

Create new htmlvis object. You have to specify params for keys that should be transformed.

### params

Define keys in input hash and library that manage this key.

Example:

        { events => Rest::HtmlVis::Events }   

Specific param is 'param.local' that defines if third party javascript and css is download from internet or from local repository.
If you want to use local repository it is important to serve static content from static directory.
Example:

        mount '/static' => Plack::App::File->new(root => "/path_to_static_directory/static/")->to_app;

## html( hash\_struct )

Convert input hash struct to html. Return html string.

# TUTORIAL

[http://psgirestapi.dovrtel.cz/](http://psgirestapi.dovrtel.cz/)

# AUTHOR

Václav Dovrtěl <vaclav.dovrtel@gmail.com>

# BUGS

Please report any bugs or feature requests to github repository.

# ACKNOWLEDGEMENTS

Inspired by [https://github.com/towhans/hochschober](https://github.com/towhans/hochschober)

# COPYRIGHT

Copyright 2015- Václav Dovrtěl

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
