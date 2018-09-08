#!/usr/bin/env perl6

use GTK::Simple;
use GTK::Simple::App;
use Config::JSON;
use WWW::vlc::Remote;
use DOM::Tiny;
class VlcStatus {...}

my \b   := {};
my \vlc := WWW::vlc::Remote.new;

with my \app := GTK::Simple::App.new: title => 'ZofVLC' {
  .set-content:
  GTK::Simple::VBox.new:
    GTK::Simple::HBox.new(
      (b<play> := GTK::Simple::Button.new: label => "▶"),
      (b<stop> := GTK::Simple::Button.new: label => "[]")),
    GTK::Simple::HBox.new(
      (b<ff>   := GTK::Simple::Button.new: label => ">>"),
      (b<fb>   := GTK::Simple::Button.new: label => "<<")),
    GTK::Simple::HBox.new(
      (b<next> := GTK::Simple::Button.new: label => ">|"),
      (b<prev> := GTK::Simple::Button.new: label => "|<")),
    (b<status> := GTK::Simple::Label.new: text => "testing"),
    (b<fst> := GTK::Simple::Button.new: label => "fetch status"),
    GTK::Simple::HBox.new(|pl-buttons vlc)
  ;
  .border-width = 20;
}

start {
    CATCH { default { say "ERROR: {.gist}"} }
    react {
        whenever b<play>.clicked { vlc.play }
        whenever b<stop>.clicked { vlc.stop }
        whenever b<ff>.clicked { vlc.seek: '+10' }
        whenever b<fb>.clicked { vlc.seek: '-10' }
        # whenever b<next>.clicked { vlc.seek: '+10' }
        # whenever b<fb>.clicked { vlc.seek: '-10' }
        whenever Supply.interval: 10 {
            b<status>.text = ~VlcStatus.new: vlc.status;
        }
    }
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


class VlcStatus {
    has DOM::Tiny:D $.dom is required;
    has Str:D $.title  = 'N/A';
    has Str:D $.artist = 'N/A';
    has Numeric:D $.pos-min = NaN;
    has Numeric:D $.pos-sec = NaN;
    has Numeric:D $.len-min = NaN;
    has Numeric:D $.len-sec = NaN;

    method new (DOM::Tiny:D \dom) {
        self.bless: dom => dom
    }
    submethod TWEAK {
        with $!dom.at: 'information' -> \info {
            info.at('[name="artist"]').all-text andthen $!artist := $_;
            info.at('[name="title"]').all-text  andthen $!title  := $_;
        }
        else {
            warn 'Failed to find <information> element in status update';
        }

        with $!dom.at('length').all-text.Numeric -> \len {
            $!len-min := Int(len/60);
            $!len-sec := Int(len - $!len-min*60);

            with $!dom.at('position').all-text.Numeric {
                my \pos := $_*len;
                $!pos-min := Int(pos/60);
                $!pos-sec := Int(pos - $!pos-min*60);
            }
        }
    }

    method Str {
        "$!title - $!artist [$!pos-min:$!pos-sec.fmt('%02d') / $!len-min:$!len-sec.fmt('%02d')]"
    }
    method gist { self.Str }
}


# <?xml version="1.0" encoding="utf-8" standalone="yes" ?>
# <root>
# <audiofilters>
#   <filter_0 /></audiofilters>
# <random>false</random>
# <position>0.017933225259185</position>
# <apiversion>3</apiversion>
# <loop>false</loop>
# <fullscreen>0</fullscreen>
# <state>playing</state>
# <length>307</length>
# <repeat>false</repeat>
# <time>5</time>
# <volume>212</volume>
# <rate>1</rate>
# <videoeffects>
#   <contrast>1</contrast>
#   <saturation>1</saturation>
#   <gamma>1</gamma>
#   <brightness>1</brightness>
#   <hue>0</hue></videoeffects>
# <version>2.1.6 Rincewind</version>
# <equalizer />
# <audiodelay>0</audiodelay>
# <subtitledelay>0</subtitledelay>
# <currentplid>13</currentplid><information>
#     <category name="meta">
#     <info name="album">Bestbreeder From 1997 To 2000</info>
#     <info name="artwork_url">file:///home/zoffix/.cache/vlc/art/artistalbum/Children%20Of%20Bodom/Bestbreeder%20From%201997%20To%202000/art.jpg</info><info name="artist">Children Of Bodom</info><info name="Style">Death Metal , Heavy Metal</info><info name="Discogs_Catalog">TFCK-87330</info><info name="Discogs_Artist_Name">Children Of Bodom</info><info name="title">Towards Dead End</info><info name="genre">Death Metal, Heavy Metal </info><info name="DISCID">9710B60C</info><info name="filename">Towards Dead End</info><info name="date">2003</info><info name="track_number">6</info><info name="Discogs_Release_ID">2021401</info><info name="Discogs_Country">Japan</info><info name="publisher">Toy&#39;s Factory</info>    </category>
#   <category name="Stream 0"><info name="Sample rate">44100 Hz</info><info name="Type">Audio</info><info name="Codec">MPEG Audio layer 1/2/3 (mpga)</info><info name="Bitrate">320 kb/s</info><info name="Channels">Stereo</info></category>  </information>
#   <stats>
#   <lostabuffers>0</lostabuffers>
# <demuxreadpackets>0</demuxreadpackets>
# <decodedaudio>210</decodedaudio>
# <demuxcorrupted>0</demuxcorrupted>
# <playedabuffers>210</playedabuffers>
# <inputbitrate>0.040361762046814</inputbitrate>
# <averageinputbitrate>0</averageinputbitrate>
# <sendbitrate>0</sendbitrate>
# <sentbytes>0</sentbytes>
# <demuxdiscontinuity>0</demuxdiscontinuity>
# <decodedvideo>0</decodedvideo>
# <demuxreadbytes>220472</demuxreadbytes>
# <averagedemuxbitrate>0</averagedemuxbitrate>
# <readbytes>223072</readbytes>
# <sentpackets>0</sentpackets>
# <displayedpictures>0</displayedpictures>
# <readpackets>219</readpackets>
# <lostpictures>0</lostpictures>
# <demuxbitrate>0.039995681494474</demuxbitrate>
#   </stats>
# </root>
#
#
#
