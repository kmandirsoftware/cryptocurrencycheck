package message;
use email;

sub report{
   my $error_text=shift;
   chomp($error_text);
   my $mail = new email();
   my $hostname = `hostname`;
   chomp $hostname;
   $mail ->set_from("image_analysis\@$hostname.com");
   $mail ->add_recipient("3038808008\@messaging.sprintpcs.com");
   $mail ->set_subject("CRYPTOCURRENCY");
   $mail ->msg_append("$error_text\n");
   $mail ->send();
   print "$error_text\n";
   exit(0);
}
1
