#!/usr/bin/perl
use strict;
use warnings;
use v5.10;

# ============================================
# BASE CLASS (Optional - shows inheritance capability)
# ============================================

package Component;
our @ISA = ();

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub power_status {
    my $self = shift;
    return "Component is operational";
}

# ============================================
# SUBSYSTEM CLASSES (Complex Internal Components)
# ============================================

package Amplifier;
our @ISA = qw(Component);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    return bless $self, $class;
}


sub on {
    my $self = shift;
    say "Amplifier: Powering on...";
}

sub off {
    my $self = shift;
    say "Amplifier: Shutting down...";
}

sub set_volume {
    my ($self, $level) = @_;
    say "Amplifier: Setting volume to $level";
}

sub set_surround_sound {
    my $self = shift;
    say "Amplifier: Enabling 5.1 surround sound";
}

package DVDPlayer;
our @ISA = qw(Component);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    $self->{movie} = '';
    return bless $self, $class;
}


sub on {
    my $self = shift;
    say "DVD Player: Powering on...";
}

sub off {
    my $self = shift;
    say "DVD Player: Shutting down...";
}

sub play {
    my ($self, $movie) = @_;
    $self->{movie} = $movie;
    say "DVD Player: Playing '$movie'";
}

sub stop {
    my $self = shift;
    say "DVD Player: Stopping playback";
}

sub eject {
    my $self = shift;
    say "DVD Player: Ejecting disc";
}

package Projector;
our @ISA = qw(Component);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    return bless $self, $class;
}


sub on {
    my $self = shift;
    say "Projector: Powering on...";
}

sub off {
    my $self = shift;
    say "Projector: Shutting down...";
}

sub set_input {
    my ($self, $source) = @_;
    say "Projector: Setting input to $source";
}

sub wide_screen_mode {
    my $self = shift;
    say "Projector: Setting widescreen mode (16:9)";
}

package TheaterLights;
our @ISA = qw(Component);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    $self->{brightness} = 100;
    return bless $self, $class;
}


sub dim {
    my ($self, $level) = @_;
    $self->{brightness} = $level;
    say "Theater Lights: Dimming to $level%";
}

sub on {
    my $self = shift;
    $self->{brightness} = 100;
    say "Theater Lights: Turning on to full brightness";
}

package Screen;
our @ISA = qw(Component);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    $self->{position} = 'up';
    return bless $self, $class;
}


sub down {
    my $self = shift;
    $self->{position} = 'down';
    say "Screen: Lowering screen";
}

sub up {
    my $self = shift;
    $self->{position} = 'up';
    say "Screen: Raising screen";
}

package PopcornPopper;
our @ISA = qw(Component);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    return bless $self, $class;
}


sub on {
    my $self = shift;
    say "Popcorn Popper: Starting...";
}

sub off {
    my $self = shift;
    say "Popcorn Popper: Shutting off";
}

sub pop {
    my $self = shift;
    say "Popcorn Popper: Popping corn!";
}

# ============================================
# FACADE CLASS (Simplified Interface)
# ============================================

package HomeTheaterFacade;
our @ISA = ();

sub new {
    my ($class, %components) = @_;
    
    my $self = {
        amp       => $components{amp},
        dvd       => $components{dvd},
        projector => $components{projector},
        lights    => $components{lights},
        screen    => $components{screen},
        popper    => $components{popper},
    };
    
    return bless $self, $class;
}


# Simple method that orchestrates multiple subsystem operations
sub watch_movie {
    my ($self, $movie) = @_;
    
    say "\n========================================";
    say "Get ready to watch '$movie'...";
    say "========================================\n";
    
    # Coordinate all subsystems in proper sequence
    $self->{popper}->on();
    $self->{popper}->pop();
    $self->{lights}->dim(10);
    $self->{screen}->down();
    $self->{projector}->on();
    $self->{projector}->wide_screen_mode();
    $self->{projector}->set_input('DVD');
    $self->{amp}->on();
    $self->{amp}->set_volume(5);
    $self->{amp}->set_surround_sound();
    $self->{dvd}->on();
    $self->{dvd}->play($movie);
    
    say "\n... Movie is now playing! Enjoy! ...\n";
}

# Simple method to end the movie
sub end_movie {
    my $self = shift;
    
    say "\n========================================";
    say "Shutting down movie theater...";
    say "========================================\n";
    
    $self->{popper}->off();
    $self->{lights}->on();
    $self->{screen}->up();
    $self->{projector}->off();
    $self->{amp}->off();
    $self->{dvd}->stop();
    $self->{dvd}->eject();
    $self->{dvd}->off();
    
    say "\n... Theater shut down complete! ...\n";
}

# Additional convenience method
sub listen_to_radio {
    my ($self, $station) = @_;
    
    say "\n========================================";
    say "Tuning to radio station $station...";
    say "========================================\n";
    
    $self->{lights}->on();
    $self->{amp}->on();
    $self->{amp}->set_volume(3);
    say "Radio: Tuned to $station FM";
    
    say "\n... Radio is playing! ...\n";
}

# ============================================
# CLIENT CODE
# ============================================

package main;

say "=" x 60;
say "FACADE PATTERN DEMONSTRATION - Home Theater System";
say "=" x 60;

# Without Facade: Client would need to manage all these objects
say "\n--- Creating Complex Subsystem Components ---\n";
my $amp       = Amplifier->new();
my $dvd       = DVDPlayer->new();
my $projector = Projector->new();
my $lights    = TheaterLights->new();
my $screen    = Screen->new();
my $popper    = PopcornPopper->new();

# Create the Facade - single point of access
say "--- Creating Facade ---\n";
my $home_theater = HomeTheaterFacade->new(
    amp       => $amp,
    dvd       => $dvd,
    projector => $projector,
    lights    => $lights,
    screen    => $screen,
    popper    => $popper,
);

# Client uses simple interface instead of complex subsystem
# Just ONE method call instead of 12+ subsystem calls!
$home_theater->watch_movie("The Matrix");

say "\n" . "=" x 60;
say "INTERMISSION - Theater is running...";
say "=" x 60;

# Another simple operation
$home_theater->end_movie();

say "\n" . "=" x 60;
say "BONUS FEATURE - Radio Mode";
say "=" x 60;

$home_theater->listen_to_radio("101.5");

say "\n" . "=" x 60;
say "DEMONSTRATION COMPLETE";
say "=" x 60;

say "\n\nKEY BENEFITS OF FACADE PATTERN:";
say "- Simplified interface (1 method vs 12+ calls)";
say "- Hides subsystem complexity from client";
say "- Loose coupling between client and subsystems";
say "- Easy to use and understand";
say "- Client doesn't need to know internal details";


#============================================================
#FACADE PATTERN DEMONSTRATION - Home Theater System
#============================================================
#
#--- Creating Complex Subsystem Components ---
#
#--- Creating Facade ---
#
#
#========================================
#Get ready to watch 'The Matrix'...
#========================================
#
#Popcorn Popper: Starting...
#Popcorn Popper: Popping corn!
#Theater Lights: Dimming to 10%
#Screen: Lowering screen
#Projector: Powering on...
#Projector: Setting widescreen mode (16:9)
#Projector: Setting input to DVD
#Amplifier: Powering on...
#Amplifier: Setting volume to 5
#Amplifier: Enabling 5.1 surround sound
#DVD Player: Powering on...
#DVD Player: Playing 'The Matrix'
#
#... Movie is now playing! Enjoy! ...
#
#
#============================================================
#INTERMISSION - Theater is running...
#============================================================
#
#========================================
#Shutting down movie theater...
#========================================
#
#Popcorn Popper: Shutting off
#Theater Lights: Turning on to full brightness
#Screen: Raising screen
#Projector: Shutting down...
#Amplifier: Shutting down...
#DVD Player: Stopping playback
#DVD Player: Ejecting disc
#DVD Player: Shutting down...
#
#... Theater shut down complete! ...
#
#
#============================================================
#BONUS FEATURE - Radio Mode
#============================================================
#
#========================================
#Tuning to radio station 101.5...
#========================================
#
#Theater Lights: Turning on to full brightness
#Amplifier: Powering on...
#Amplifier: Setting volume to 3
#Radio: Tuned to 101.5 FM
#
#... Radio is playing! ...
#
#
#============================================================
#DEMONSTRATION COMPLETE
#============================================================
#
#
#KEY BENEFITS OF FACADE PATTERN:
#- Simplified interface (1 method vs 12+ calls)
#- Hides subsystem complexity from client
#- Loose coupling between client and subsystems
#- Easy to use and understand
#- Client doesn't need to know internal details
