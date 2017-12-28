#
#===============================================================================
#
#         FILE:  email.pm
#
#  DESCRIPTION:  email module for generic use
#
#       AUTHOR:  Keith Gerhards
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  02/16/2017 01:26:02 PM MST
#     REVISION:  ---
#===============================================================================

package email;

use strict;
use warnings;

use MIME::Lite;
use Net::SMTP;
use Data::Dumper;


#===  FUNCTION  ================================================================
#         NAME:  new
#      PURPOSE:  create new email class
#  DESCRIPTION:  
#   PARAMETERS:  n/a
#      RETURNS:  n/a
#===============================================================================
sub new 
{
   my $proto = shift @_;
   my $class = ref($proto) || $proto;
   my $self = {};

   $self->{recipients} = [];
   $self->{msg} = "";
   $self->{subject} = "";
   $self->{from} = "";
   $self->{files} = {};


   bless($self,$class);
   return $self;
}

#===  FUNCTION  ================================================================
#         NAME:  DESTROY
#      PURPOSE:  tear down email class
#  DESCRIPTION:  
#   PARAMETERS:  
#      RETURNS:  n/a
#===============================================================================
sub DESTROY
{
}

#===  FUNCTION  ================================================================
#         NAME:  add_recipient
#      PURPOSE:  add a new recipient to the email being created
#  DESCRIPTION:  
#   PARAMETERS:  recipient - name
#      RETURNS:  n/a
#===============================================================================
sub add_recipient
{
   my $self = shift;
   my $recipient = shift;

   if($self->{recipients} eq  "")
   {
      $self->{recipients}.= "$recipient";
   }
   else
   {
      $self->{recipients}.= ",$recipient";
   }

   return;
}

#===  FUNCTION  ================================================================
#         NAME:  set_from
#      PURPOSE:  set the email from address
#  DESCRIPTION:  
#   PARAMETERS:  from - email from string
#      RETURNS:  n/a
#===============================================================================
sub set_from
{
   my $self = shift;
   my $from = shift;

   $self ->{from} = $from;

   return;
}

#===  FUNCTION  ================================================================
#         NAME:  set_subject
#      PURPOSE:  set the subject of the outgoing email
#  DESCRIPTION:  
#   PARAMETERS:  subject - string
#      RETURNS:  n/a
#===============================================================================
sub set_subject
{
   my $self = shift;
   my $subject = shift;

   $self ->{subject} = $subject;

   return;
}

#===  FUNCTION  ================================================================
#         NAME:  msg_append
#      PURPOSE:  append some text to the message body
#  DESCRIPTION:  
#   PARAMETERS:  data - text to append
#      RETURNS:  n/a
#===============================================================================
sub msg_append
{
   my $self = shift;
   my $data = shift;

   $self->{msg} .= $data;

   return;
}

#===  FUNCTION  ================================================================
#         NAME:  msg_set_title
#      PURPOSE:  set the title of the email
#  DESCRIPTION:  
#   PARAMETERS:  title - string
#      RETURNS:  n/a
#===============================================================================
sub msg_set_title
{
   my $self = shift;
   my $title = shift;

   $self->{subject} = $title;
   
   return;
}

#===  FUNCTION  ================================================================
#         NAME:  attach file
#      PURPOSE:  attach a file to the MIME headers
#  DESCRIPTION:  note: the file cannot have spaces etc in the path
#   PARAMETERS:  name - name of the file
#                location - location of the file (no spaces etc)
#      RETURNS:  n/a
#===============================================================================
sub attach_file
{
   my $self = shift;
   my $name = shift;
   my $location = shift;

   #my %files = %{$self->{files}};

   $self->{files}->{$name} = $location;

   print STDOUT Dumper $self->{files};

   return;
}

#===  FUNCTION  ================================================================
#         NAME:  send
#      PURPOSE:  sends the email
#  DESCRIPTION:  
#   PARAMETERS:  
#      RETURNS:  n/a
#===============================================================================
sub send
{
   my $self = shift;

#   my $smtp = Net::SMTP->new("localhost",
#                    Hello => "localhost",
#                    Timeout => 60) 
#      or die "cannot create smtp connection. $!\n";
#
#   $smtp ->mail($self ->{from});
#   #$smtp->recipient( qw($self ->{recipients}) );
#   $smtp ->recipient( $self ->{recipients});
#
#   $smtp ->data;
#   $smtp ->datasend("From: " . $self ->{from} . "\n");
#   $smtp ->datasend("To: " . $self ->{recipient} . "\n");
#   $smtp ->datasend("Subject: " . $self ->{subject} . "\n");
#   $smtp ->datasend("\n");
#   $smtp ->datasend($self ->{msg});
#
#   $smtp ->dataend;
#   $smtp ->quit;


   ### Adjust sender, recipient and your SMTP mailhost
   my $from_address = $self ->{from};
   my $to_address = $self ->{recipients};
   my $mail_host = "localhost";
   ### Adjust subject and body message
   my $subject = $self ->{subject};

   ### Create the multipart container
   my $msg = MIME::Lite->new (
     From => $from_address,
     To => $to_address,
     Subject => $subject,
     Type =>'multipart/mixed'
   ) or die "Error creating multipart container: $!\n";

   ### Add the text message part
   $msg->attach (
     Type => 'TEXT',
     Data => $self ->{msg},
   ) or die "Error adding the text message part: $!\n";

   print STDOUT Dumper %{$self->{files}};
   foreach my $file (keys %{$self->{files}})
   {
      my $type = "";
      if($file =~ /\w+\.(\w+)/)
      {
         if(($1 eq "jpeg") or ($1 eq "jpg"))
         {
            $type = "image/jpeg";
         }
         elsif($1 eq "gif")
         {
            $type = "image/gif";
         }
         elsif($1 eq "png")
         {
            $type = "image/png";
         }
         elsif($1 eq "zip")
         {
            $type = 'application/zip';
         }
         elsif($1 eq "tgz")
         {
           $type = 'application/x-tar';
         }
         elsif($1 eq "html")
         {
            $type = 'text/html';
         }
         else
         {
            $type = "TEXT";
         }
      }
      else
      {
         $type = "TEXT";
      }

      $msg->attach (
         Type => $type,
         Path => $self->{files}->{$file},
         Filename => $file,
         Disposition => 'attachment'
      ) or die "Error adding $file: $!\n";
   }
   ### Send the Message
   MIME::Lite->send('smtp', $mail_host, Timeout=>300);
   #MIME::Lite->send('smtp', $mail_host, Timeout=>300, Debug=>1, Notify => ['FAILURE','DELAY'], SkipBad => 1 );

   $msg->send;
}

1;
