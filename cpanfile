requires 'JSON::XS';
requires 'Plack::Request';
requires 'YAML::Syck';
requires 'perl', '5.006';
requires 'File::ShareDir';

on build => sub {
    requires 'Test::More';
};
