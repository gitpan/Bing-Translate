use strict;
use warnings;
package Bing::Translate;
# ABSTRACT: Class for using the functions, provided by the Microsoft Bing Translate API.

# for Wide character in print at
use utf8;
binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');
binmode(STDERR, ':encoding(utf8)');

# for translate
use LWP::UserAgent;
use HTTP::Headers;
use URI::Escape;
# for getToken
use JSON;
use Data::Dumper;
use HTTP::Request::Common qw(POST);

#http://stackoverflow.com/questions/392135/what-exactly-does-perls-bless-do
#http://www.tutorialspoint.com/perl/perl_oo_perl.htm
sub new {
        my $class = shift;
        my $self = {
                'id' => shift,
                'secret' => shift,
        };
        bless $self, $class;
        return $self;
}

sub decodeJSON {
        my $rawJSON = shift;
        my $json = new JSON;
        my $obj = $json->decode($rawJSON);
        #print "The structure of obj: ".Dumper($obj);
        #obj is a hash
        #print "$obj->{'access_token'}\n";
        return $obj->{'access_token'};
}

sub translate {
        #需要給主程式呼叫時, 要建立 $self
        my ($self, $text, $from, $to) = @_;
        $text = uri_escape($text);

        my $apiuri = "http://api.microsofttranslator.com/v2/Http.svc/Translate?"."text=".$text."&from=$from"."&to=$to"."&contentType=text/plain";
        my $agent_name='myagent';
        my $ua = LWP::UserAgent->new($agent_name);
        my $request = HTTP::Request->new(GET=>$apiuri);
        my $authToken = &getToken;
        #$request->header(Accept=>'text/html');
        $request->header(Authorization=>$authToken);

        my $response = $ua->request($request);
        #print $response->as_string, "\n";
        if ($response->is_success) {
                #print $response->decoded_content;
                my $content = $response->decoded_content;
                if ($content =~ />(.*)<\/string>/) {
                        return $1;
                }
        } else {
                return "translate fail";
        }
}

sub getToken {
        #my ($id, $secret) = @_;
        my $self = shift;
        my $id = $self->{'id'};
        my $secret = $self->{'secret'};

        my $ua = LWP::UserAgent->new() or die;
        $ua->ssl_opts (verify_hostname => 0);
        my $url = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13/";
        my $request = POST( $url, [ grant_type => "client_credentials", scope => "http://api.microsofttranslator.com", client_id => "$id", client_secret => "$secret" ] );
#       my $content = $ua->request($request)->as_string() or die;
        my $response = $ua->request($request);
        my $content;
        my $authToken;
        if ($response->is_success) {
                #print $response->decoded_content;
                $content = $response->decoded_content;
                my $accessToken = &decodeJSON($content);
                $authToken = "Bearer" . " " . "$accessToken";
        } else {
                die $response->status_line;
        }
        return $authToken;
}

1;

__END__

=pod

=head1 NAME

Bing::Translate - Class for using the functions, provided by the Microsoft Bing Translate API.

=head1 VERSION

version 0.001

=head1 AUTHOR

Meng-Jie Wang <taiwanwolf.iphone@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Meng-Jie Wang.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
