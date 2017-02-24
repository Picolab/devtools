#!/usr/bin/perl -w

use Getopt::Std;
use LWP::Simple;

my $flush_rids = [
        "v1_devtools.prod",
        "v1_devtools_bootstrap.prod",
        "v1_wrangler.prod"
];

my $machines = ["cs.kobj.net", "kibdev.kobj.net"];

foreach my $machine (@{$machines}) {
  print "flushing $machine...\n";
  my $content = get("https://$machine/ruleset/flush/" . join(";", @{$flush_rids}) );
  print $content, "\n\n";
}
