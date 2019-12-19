package KeyedMutex::Redis;
use strict;
use warnings;
use RedisDB;
use Time::HiRes ();

our $VERSION = '0.01';

sub new {
    my ($class, $args) = @_;

    my $redis = RedisDB->new(
    host => $args->{redis_host},
    port => $args->{redis_port},
    );
    my $self = bless {
    redis              => $redis,
    lock_wait_interval => $args->{lock_wait_interval} || 0.1,
    max_retry          => $args->{max_retry} || 10,
    lock_key           => undef,
    }, $class;

    $self;
}

sub lock {
    my ($self, $lock_key) = @_;

    $self->{lock_key} = $lock_key;
    my $locked=0;
    my $i=0;
    while ($self->{max_retry}==0 || ++$i <= $self->{max_retry}) {
    $self->{redis}->send_command('SETNX',  $lock_key, 1);
    $locked = $self->{redis}->get_reply;
    last if $locked;
    Time::HiRes::sleep($self->{lock_wait_interval} * rand(1));
    }
    $locked;
}

sub release {
    my $self = shift;

    my $lock_key = delete $self->{lock_key};
    $self->{redis}->send_command('DEL', $lock_key);
    $self->{redis}->get_reply;
}

1;
