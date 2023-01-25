# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

# get selenium object
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {

        my $HelperObject    = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

        # get dashboard Image plugin default sysconfig
        my %ImageConfig = $SysConfigObject->SettingGet(
            Name    => 'DashboardBackend###0200-Image',
            Default => 1,
        );

        $HelperObject->ConfigSettingChange(
            Valid => 1,
            Key   => 'DashboardBackend###0200-Image',
            Value => $ImageConfig{EffectiveValue},
        );

        # create test user and login
        my $TestUserLogin = $HelperObject->TestUserCreate(
            Groups => [ 'admin', 'users' ],
        ) || die "Did not get test user";

        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # test if Image plugin shows correct link
        my $ImageLink = $ImageConfig{EffectiveValue}->{Link};
        $Self->True(
            index( $Selenium->get_page_source(), $ImageLink ) > -1,
            "Image dashboard plugin link '$ImageLink' - found",
        );
    }
);

1;