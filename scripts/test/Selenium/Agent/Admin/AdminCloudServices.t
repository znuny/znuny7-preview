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
use File::Path qw(mkpath rmtree);

# get selenium object
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {

        my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

        # make sure to enable cloud services
        $HelperObject->ConfigSettingChange(
            Valid => 1,
            Key   => 'CloudServices::Disabled',
            Value => 0,
        );

        # create test user and login
        my $TestUserLogin = $HelperObject->TestUserCreate(
            Groups => ['admin'],
        ) || die "Did not get test user";

        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        # get script alias
        my $ScriptAlias = $ConfigObject->Get('ScriptAlias');

        # navigate to the AdminCloudServices screen in the test
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AdminCloudServices");

        # check available Cloud Services table
        $Selenium->find_element( "table",             'css' );
        $Selenium->find_element( "table thead tr th", 'css' );
        $Selenium->find_element( "table tbody tr td", 'css' );

        # check 'Support data collector' link
        $Self->True(
            $Selenium->find_element("//a[contains(\@href, \'Action=AdminCloudServiceSupportDataCollector' )]"),
            "'Support data collector' link is found on screen.",
        );

        # check breadcrumb on screen
        for my $BreadcrumbText ('Cloud Service Management') {
            $Selenium->ElementExists(
                Selector     => ".BreadCrumb>li>[title='$BreadcrumbText']",
                SelectorType => 'css',
            );
        }

    }
);

1;
