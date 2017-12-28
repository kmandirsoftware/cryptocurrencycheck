#
#===============================================================================
#
#         FILE:  main.pl
#
#  DESCRIPTION:  Send message when bitcoin or Ethereum hit strike price. Uses
#                API from Kraken website https://www.kraken.com/en-us/help/api
#
#       AUTHOR:  Keith Gerhards
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  02/16/2017 01:26:02 PM MST
#     REVISION:  ---
#===============================================================================
use Finance::Bank::Kraken;
use JSON;
use Data::Dumper;
use message;

my $mykrakenkey = "your key";
my $mykrakensecret = "your secrete";
my $api = new Finance::Bank::Kraken;
$api->key($mykrakenkey);
$api->secret($mykrakensecret);
my $check=0;
while($check eq 0){
   my $res = $api->call(Public, 'Ticker', ['pair=ETHUSD,XXBTZUSD']);
   my $bitcoin = from_json($res)->{'result'}->{'XXBTZUSD'}->{'c'}[0];

   printf "1 ETH is %f USD\n",
             from_json($res)->{'result'}->{'XETHZUSD'}->{'c'}[0]
             unless $res =~ /^5/;

   printf "1 BITCOIN is %f USD\n",
             from_json($res)->{'result'}->{'XXBTZUSD'}->{'c'}[0]
             unless $res =~ /^5/;
   if($bitcoin < 14600){
      $check=1;
      message::report("BITCOIN less than $14,600 : $bitcoin");
   }
   sleep(60);
}
message::report("BITCOIN less than $14,000 : $bitcoin");

