#!/usr/bin/perl
use strict;
use warnings;

# ============================================================================
# RECEIVER - The object that performs the actual work
# ============================================================================
package TextEditor;

sub new {
    my $class = shift;
    return bless {
        text => "",
        history => []
    }, $class;
}

sub insert_text {
    my ($self, $text, $position) = @_;
    $position //= length($self->{text});
    
    my $before = substr($self->{text}, 0, $position);
    my $after = substr($self->{text}, $position);
    $self->{text} = $before . $text . $after;
    
    print "[Editor] Inserted '$text' at position $position\n";
    print "[Editor] Current text: '$self->{text}'\n";
}

sub delete_text {
    my ($self, $position, $length) = @_;
    
    my $deleted = substr($self->{text}, $position, $length, "");
    print "[Editor] Deleted '$deleted' at position $position\n";
    print "[Editor] Current text: '$self->{text}'\n";
    
    return $deleted;
}

sub get_text {
    my $self = shift;
    return $self->{text};
}

sub show {
    my $self = shift;
    print "[Editor] Text: '$self->{text}'\n";
}

# ============================================================================
# COMMAND INTERFACE - Base class for all commands
# ============================================================================
package Command;

sub new {
    my ($class, $receiver) = @_;
    return bless {
        receiver => $receiver
    }, $class;
}

sub execute {
    die "Subclass must implement execute()";
}

sub undo {
    die "Subclass must implement undo()";
}

# ============================================================================
# CONCRETE COMMANDS
# ============================================================================

# Insert Text Command
package InsertCommand;
our @ISA = qw(Command);

sub new {
    my ($class, $receiver, $text, $position) = @_;
    my $self = $class->SUPER::new($receiver);
    $self->{text} = $text;
    $self->{position} = $position // length($receiver->get_text());
    return $self;
}

sub execute {
    my $self = shift;
    print "\n[Command] Executing INSERT\n";
    $self->{receiver}->insert_text($self->{text}, $self->{position});
}

sub undo {
    my $self = shift;
    print "\n[Command] Undoing INSERT\n";
    $self->{receiver}->delete_text($self->{position}, length($self->{text}));
}

# Delete Text Command
package DeleteCommand;
our @ISA = qw(Command);

sub new {
    my ($class, $receiver, $position, $length) = @_;
    my $self = $class->SUPER::new($receiver);
    $self->{position} = $position;
    $self->{length} = $length;
    $self->{deleted_text} = undef;
    return $self;
}

sub execute {
    my $self = shift;
    print "\n[Command] Executing DELETE\n";
    $self->{deleted_text} = $self->{receiver}->delete_text(
        $self->{position}, 
        $self->{length}
    );
}

sub undo {
    my $self = shift;
    print "\n[Command] Undoing DELETE\n";
    $self->{receiver}->insert_text($self->{deleted_text}, $self->{position});
}

# Replace Text Command (Macro - combines delete and insert)
package ReplaceCommand;
our @ISA = qw(Command);

sub new {
    my ($class, $receiver, $position, $length, $new_text) = @_;
    my $self = $class->SUPER::new($receiver);
    $self->{delete_cmd} = DeleteCommand->new($receiver, $position, $length);
    $self->{insert_cmd} = InsertCommand->new($receiver, $new_text, $position);
    return $self;
}

sub execute {
    my $self = shift;
    print "\n[Command] Executing REPLACE (macro)\n";
    $self->{delete_cmd}->execute();
    $self->{insert_cmd}->execute();
}

sub undo {
    my $self = shift;
    print "\n[Command] Undoing REPLACE (macro)\n";
    $self->{insert_cmd}->undo();
    $self->{delete_cmd}->undo();
}

# ============================================================================
# INVOKER - Command manager with queue and undo capability
# ============================================================================
package CommandInvoker;

sub new {
    my $class = shift;
    return bless {
        history => [],
        undo_stack => []
    }, $class;
}

sub execute_command {
    my ($self, $command) = @_;
    $command->execute();
    push @{$self->{history}}, $command;
    push @{$self->{undo_stack}}, $command;
    # Clear redo capability when new command executed
}

sub undo {
    my $self = shift;
    
    if (@{$self->{undo_stack}}) {
        my $command = pop @{$self->{undo_stack}};
        $command->undo();
    } else {
        print "\n[Invoker] Nothing to undo!\n";
    }
}

sub show_history {
    my $self = shift;
    print "\n[Invoker] Command History:\n";
    for my $i (0 .. $#{$self->{history}}) {
        my $cmd = $self->{history}[$i];
        my $type = ref($cmd);
        $type =~ s/Command$//;
        print "  " . ($i + 1) . ". $type\n";
    }
}

sub execute_batch {
    my ($self, @commands) = @_;
    print "\n[Invoker] Executing batch of " . scalar(@commands) . " commands\n";
    foreach my $cmd (@commands) {
        $self->execute_command($cmd);
    }
}

# ============================================================================
# MAIN DEMONSTRATION
# ============================================================================
package main;

print "=" x 70 . "\n";
print "COMMAND PATTERN DEMONSTRATION - Text Editor\n";
print "=" x 70 . "\n";

# Create receiver (text editor)
my $editor = TextEditor->new();

# Create invoker (command manager)
my $invoker = CommandInvoker->new();

print "\n### SCENARIO 1: Basic Commands ###\n";

# Create and execute commands
my $cmd1 = InsertCommand->new($editor, "Hello");
$invoker->execute_command($cmd1);

my $cmd2 = InsertCommand->new($editor, " World");
$invoker->execute_command($cmd2);

my $cmd3 = InsertCommand->new($editor, "!", undef);
$invoker->execute_command($cmd3);

print "\n### SCENARIO 2: Undo Operations ###\n";

$invoker->undo();  # Undo "!"
$invoker->undo();  # Undo " World"

print "\n### SCENARIO 3: Macro Command (Replace) ###\n";

my $cmd4 = ReplaceCommand->new($editor, 0, 5, "Greetings");
$invoker->execute_command($cmd4);

print "\n### SCENARIO 4: Batch Execution (Queue) ###\n";

my @batch = (
    InsertCommand->new($editor, " to"),
    InsertCommand->new($editor, " all"),
    InsertCommand->new($editor, "!")
);

$invoker->execute_batch(@batch);

print "\n### SCENARIO 5: Multiple Undos ###\n";

$invoker->undo();
$invoker->undo();

print "\n### SCENARIO 6: Command History ###\n";

$invoker->show_history();

print "\n### Final State ###\n";
$editor->show();

print "\n" . "=" x 70 . "\n";
print "KEY CONCEPTS DEMONSTRATED:\n";
print "=" x 70 . "\n";
print "1. Commands as objects (encapsulation)\n";
print "2. Separation of invoker and receiver\n";
print "3. Undo capability\n";
print "4. Command history/logging\n";
print "5. Command queuing (batch execution)\n";
print "6. Macro commands (composite)\n";
print "=" x 70 . "\n";

# ======================================================================
#COMMAND PATTERN DEMONSTRATION - Text Editor
#======================================================================
#
#### SCENARIO 1: Basic Commands ###
#
#[Command] Executing INSERT
#[Editor] Inserted 'Hello' at position 0
#[Editor] Current text: 'Hello'
#
#[Command] Executing INSERT
#[Editor] Inserted ' World' at position 5
#[Editor] Current text: 'Hello World'
#
#[Command] Executing INSERT
#[Editor] Inserted '!' at position 11
#[Editor] Current text: 'Hello World!'
#
#### SCENARIO 2: Undo Operations ###
#
#[Command] Undoing INSERT
#[Editor] Deleted '!' at position 11
#[Editor] Current text: 'Hello World'
#
#[Command] Undoing INSERT
#[Editor] Deleted ' World' at position 5
#[Editor] Current text: 'Hello'
#
#### SCENARIO 3: Macro Command (Replace) ###
#
#[Command] Executing REPLACE (macro)
#
#[Command] Executing DELETE
#[Editor] Deleted 'Hello' at position 0
#[Editor] Current text: ''
#
#[Command] Executing INSERT
#[Editor] Inserted 'Greetings' at position 0
#[Editor] Current text: 'Greetings'
#
#### SCENARIO 4: Batch Execution (Queue) ###
#
#[Invoker] Executing batch of 3 commands
#
#[Command] Executing INSERT
#[Editor] Inserted ' to' at position 9
#[Editor] Current text: 'Greetings to'
#
#[Command] Executing INSERT
#[Editor] Inserted ' all' at position 9
#[Editor] Current text: 'Greetings all to'
#
#[Command] Executing INSERT
#[Editor] Inserted '!' at position 9
#[Editor] Current text: 'Greetings! all to'
#
#### SCENARIO 5: Multiple Undos ###
#
#[Command] Undoing INSERT
#[Editor] Deleted '!' at position 9
#[Editor] Current text: 'Greetings all to'
#
#[Command] Undoing INSERT
#[Editor] Deleted ' all' at position 9
#[Editor] Current text: 'Greetings to'
#
#### SCENARIO 6: Command History ###
#
#[Invoker] Command History:
#  1. Insert
#  2. Insert
#  3. Insert
#  4. Replace
#  5. Insert
#  6. Insert
#  7. Insert
#
#### Final State ###
#[Editor] Text: 'Greetings to'
#
#======================================================================
#KEY CONCEPTS DEMONSTRATED:
#======================================================================
#1. Commands as objects (encapsulation)
#2. Separation of invoker and receiver
#3. Undo capability
#4. Command history/logging
#5. Command queuing (batch execution)
#6. Macro commands (composite)
#======================================================================
