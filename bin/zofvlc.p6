#!/usr/bin/env perl6

use GTK::Simple;
use GTK::Simple::App;
use Config::JSON;
use WWW::vlc::Remote;

my \b   := {};
my \vlc := WWW::vlc::Remote.new;

with my \app := GTK::Simple::App.new: title => 'ZofVLC' {
  .set-content:
  GTK::Simple::VBox.new:
    GTK::Simple::HBox.new(
      (b<play> := GTK::Simple::Button.new: label => "▶"),
      (b<stop> := GTK::Simple::Button.new: label => "[]")),
    GTK::Simple::HBox.new(
      (b<ff>   := GTK::Simple::Button.new: label => "<<"),
      (b<fb>   := GTK::Simple::Button.new: label => ">>")),
    GTK::Simple::HBox.new(
      (b<next> := GTK::Simple::Button.new: label => ">|"),
      (b<prev> := GTK::Simple::Button.new: label => "|<")),
    GTK::Simple::HBox.new(|pl-buttons vlc)
  ;
  .border-width = 20;
}

start react {
    whenever b<play>.clicked { vlc.play }
    whenever b<stop>.clicked { vlc.stop }
    whenever b<ff>.clicked { vlc.seek: '+10' }
    whenever b<fb>.clicked { vlc.seek: '-10' }
}

app.run;

sub pl-buttons(WWW::vlc::Remote \vlc) {
  (my \root := jconf('pl-root').IO).d or die "Missing playlist root dir";
  root.dir.grep(*.d).map: -> \path {
    with GTK::Simple::Button.new: label => path.basename {
      .clicked.tap: {
        vlc.enqueue-and-play: path.absolute;
      }
      $_
    }
  }
}
