#! /bin/env perl
use strict;
use warnings;
use KeyedMutex::Redis;

my $kr = KeyedMutex::Redis->new(
    +{
        redis_host => 'localhost',
        redis_port => 6379,
    }
);
if (my $lock = $kr->lock('lock_key')) {
    # Lock 취득 후의 처리를 수행
    $kr->release; # Lock의 해제
}
