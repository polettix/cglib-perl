#!/usr/bin/env perl
package Romeo::Util::DateTime;
use v5.24;
use warnings;
use experimental 'signatures';
use utf8;
use POSIX 'strftime';
use Time::Local qw< timelocal timegm >;

use constant EPOCH_AD_OFFSET  => 116444736000000000;
no warnings 'portable';
use constant AD_NEVER => 0x7fff_ffff_ffff_ffff;

use Exporter qw< import >;

our @EXPORT_OK = qw<
   epoch_to_ad 
   epoch_to_local 
   epoch_to_gm 
   epoch_to_t 

   ad_to_epoch 
   iso_to_epoch
   today_to_epoch
   dwim_to_epoch 

   iso_parse 
   offset 
>;

sub epoch_to_ad ($epoch) {
   die "invalid epoch\n" if $epoch !~ m{\A (?: 0 | [1-9]\d*) \z}mxs;
   return ($epoch * 10_000_000 + EPOCH_AD_OFFSET);
}

sub epoch_to_local ($epoch) {
   die "invalid epoch\n" if $epoch !~ m{\A (?: 0 | [1-9]\d*) \z}mxs;
   return strftime('%Y-%m-%dT%H:%M:%S%z', localtime($epoch));
}

sub epoch_to_gm ($epoch) {
   die "invalid epoch\n" if $epoch !~ m{\A (?: 0 | [1-9]\d*) \z}mxs;
   return strftime('%Y-%m-%dT%H:%M:%S+0000', gmtime($epoch));
}

sub seconds_to_t ($epoch) {
   state $mods = [
      [ s => 60, 2 ],
      [ m => 60, 2 ],
      [ h => 24, 2 ],
   ];
   die "invalid epoch\n" if $epoch !~ m{\A (?: 0 | [1-9]\d*) \z}mxs;
   my $retval = '';
   for my $spec ($mods->@*) {
      last unless $epoch;
      my ($unit, $mod, $len) = $spec->@*;
      my $value = $epoch % $mod;
      $retval = sprintf("%0${len}d$unit", $value) . $retval
         if length($retval) || $value > 0;
      $epoch = ($epoch - $value) / $mod;
   }
   $retval = sprintf('%dd', $epoch) . $retval if $epoch;
   return $retval;
}

sub ad_to_epoch ($adtime) {
   die "invalid AD time\n" if
      ($adtime !~ m{\A [1-9]\d* \z}mxs)
      || $adtime < EPOCH_AD_OFFSET
      || $adtime >= AD_NEVER;
   return (($adtime - EPOCH_AD_OFFSET) / 10_000_000);
}

sub iso_to_epoch ($ts, $dtz = 'local') {
   my ($timeref, $tz) = iso_parse($ts);
   return _specific_to_epoch($timeref, $tz) if defined $tz;
   return timegm($timeref->@*)
      if $dtz =~ m{\A(?: gm | utc | 0 )\z}imxs;
   return timelocal($timeref->@*)
      if fc($dtz // 'local') eq 'local';
   return _specific_to_epoch($timeref, $dtz)
}

sub _specific_to_epoch ($timeref, $tz) {
   my $base = timegm($timeref->@*);
   $tz = '+0000' if lc($tz) eq 'z';
   my ($sign, $oh, $om) = $tz =~ m{\A ([-+]) (\d\d) (\d\d)? \z}mxs;
   my $offset = 60 * ($oh * 60 + ($om // 0));
   $offset = - $offset if $sign eq '+'; # go backwards
   return $base + $offset;
}

sub offset ($base, $offset) {
   return $base unless length($offset // '');
   $offset = lc($offset);
   my $sign_factor = 1;
   while (length($offset)) {
      my $sign = $offset =~ m{\A [-+]}mxs ? substr $offset, 0, 1, '' : '=';
      $sign_factor = $sign eq '-' ? -1 : $sign eq '+' ? 1 : $sign_factor;
      my ($amount, $unit) = $offset =~ m{\A (\d+) ([smhdw])}mxs
         or die "invalid offset\n";
      substr($offset, 0, length($amount) + length($unit), '');
      $amount =~ s{\A 0+}{}mxs;
      $amount ||= 0;
      if ($unit eq 's') {
         $base += $sign_factor * $amount;
      }
      elsif ($unit eq 'm') {
         $amount *= 60;
         $base += $sign_factor * $amount;
      }
      elsif ($unit eq 'h') {
         $amount *= 3600;
         $base += $sign_factor * $amount;
      }
      else { # advance preserving the hour of the day... if possible!
         $amount *= 7 if $unit eq 'w'; # 7 days per week

         # save the initial "offset inside the day"
         my ($ss, $sm, $sh) = localtime($base);
         my $exp_day_offset = $ss + 60 * ($sm + 60 * $sh);

         # approximate the jump
         $amount *= 24 * 3600; # tentative days to seconds
         $base += $sign_factor * $amount;

         # adjust by landing offset
         my ($ls, $lm, $lh) = localtime($base);
         my $got_day_offset = $ls + 60 * ($lm + 60 * $lh);
         $base += ($exp_day_offset - $got_day_offset) % (24 * 3600);
      }
   }

   return $base;
}

sub today_to_epoch {
   my ($second, $minute, $hour, $day, $em, $ey) = localtime;
   timelocal(0, 0, 0, $day, $em, $ey);
}

sub dwim_to_epoch ($ts, $dtz = 'local') {
   die "no input\n" unless ($ts // '') =~ m{\S}mxs;

   $ts =~ s{\A\s+|\s+\z}{}gmxs;
   my ($start, $offset) = lc($ts) =~ m{
      \A 
         (
            (?:
                  now | yesterday | today | tomorrow  # really dwim stuff
               |  iso(?: -? 8601)?[:/=] .+?           # ISO-8601
               |  ad              [:/=] .+?           # Active Directory
               |  \d+                                 # AD or epoch
               |  .+?                                 # anything else
            )?
         )
         ( (?: [-+] (?: \d+ [smhdw])+ )* )             # offset
      \z
   }imxs or die "invalid dwim input <$ts>\n";
   $start = 'now' unless length($start);

   my $base = $start eq 'now' ? time()
   : $start eq 'yesterday'    ? offset(today_to_epoch(), '-1d')
   : $start eq 'today'        ? today_to_epoch()
   : $start eq 'tomorrow'     ? offset(today_to_epoch(), '+1d')
   : $start =~ m(\A iso (?: 8601)? [:/=] (.+))mxs ? iso_to_epoch($1, $dtz)
   : $start =~ m{\A ad             [:/=] (.+)}mxs ? ad_to_epoch($1)
   : $start =~ m{\D}mxs       ? iso_to_epoch($start, $dtz)
   : length($start) >= 18     ? ad_to_epoch($start)
   :                            0 + $start;

   return offset($base, $offset);
}

sub iso_parse ($ts) {
   my ($date, $time, $tz) = $ts =~ m{
      \A
         (\d{8} | \d{4} [-/] \d\d [-/] \d\d)
         (?:
            [tT\ ]
            (\d{6} | \d\d   :  \d\d   :  \d\d)
            ( [zZ] | [-+] \d\d (?:\d\d)? )?
         )?
      \z
   }mxs or die "invalid ISO8601 input data <$ts>\n";
   my ($year, $month, $day) = $date =~ m{(\d{4})\D?(\d\d)\D?(\d\d)}mxs;
   my ($hour, $minute, $second) =
      ($time || '00:00:00') =~ m{(\d\d):?(\d\d):?(\d\d)}mxs;

   return (
      [$second + 0, $minute + 0, $hour + 0, $day + 0, $month - 1, $year + 0],
      $tz
   );
}

########################################################################
# modulino stuff to test a few things out, can be removed
sub (@argv) {
   require Data::Dumper;
   Data::Dumper->import('Dumper');
   #   iso_parse, iso_to_epoch
   {
      my $str = '2025-03-18T07:34:12+0100';
      my ($ar, $tz) = iso_parse($str);
      print Dumper([$str, $ar, $tz]);
      
      my $epoch = iso_to_epoch($str);
      print Dumper([$str, $epoch, gmtime($epoch) . ' (UTC)']);
   }

   {
      my $epoch = today_to_epoch();
      print Dumper(
         [
            $epoch,
            epoch_to_local($epoch) . ' (local)',
            localtime($epoch) . ' (local)',
            epoch_to_gm($epoch) . ' (UTC)',
            gmtime($epoch) . ' (UTC)',
         ]
      );
   }

   {
      my $epoch = time();
      print Dumper(
         [
            $epoch,
            epoch_to_local($epoch) . ' (local)',
            localtime($epoch) . ' (local)',
            epoch_to_gm($epoch) . ' (UTC)',
            gmtime($epoch) . ' (UTC)',
            epoch_to_ad($epoch),
         ]
      );
   }

   {
      my $delta_seconds = 3726; # 1 hour, 2 minutes, 6 seconds
      print Dumper(
         [
            $delta_seconds,
            seconds_to_t($delta_seconds),
         ]
      );
   }

   {
      my $epoch = time();
      my $ad = epoch_to_ad($epoch);
      my $back = ad_to_epoch($ad);
      print Dumper(
         [
            $epoch,
            $ad,
            $back,
            $back - $epoch,
         ]
      );
   }

   {
      my $offset = '1d2h3m4s';
      my $start = iso_to_epoch('20250318T075100', 'utc');
      my $end   = offset($start, $offset);
      my $delta = $end - $start;
      my $edelta = 93784;
      print Dumper(
         [
            $start,
            $offset,
            $end,
            $delta,
            $delta - $edelta,
         ]
      );
   }

   #   dwim_to_epoch 
   {
      my $ts = '2025-03-18 07:55:00';
      my $epoch = dwim_to_epoch($ts);
      print Dumper(
         [
            $ts,
            $epoch,
            iso_to_epoch($ts),
         ]
      );
   }
}->(@ARGV) unless caller();

1;
