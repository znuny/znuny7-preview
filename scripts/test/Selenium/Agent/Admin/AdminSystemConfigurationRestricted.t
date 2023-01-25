# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;
use utf8;

use vars (qw($Self));

my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {

        my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
        my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

        $HelperObject->ConfigSettingChange(
            Valid => 1,
            Key   => 'ConfigLevel',
            Value => '300',
        );

        # Create test user and login.
        my $TestUserLogin = $HelperObject->TestUserCreate(
            Groups => ['admin'],
        ) || die "Did not get test user";

        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        my $ScriptAlias = $ConfigObject->Get('ScriptAlias');

        # Navigate to AdminSysConfig screen.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AdminSystemConfiguration;");

        # Wait until page is loaded with jstree content in sidebar.
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $("#SysConfigSearch").length && $("#ConfigTree > ul:visible").length;',
        );

        $Selenium->find_element( "#SysConfigSearch", "css" )->clear();
        $Selenium->find_element( "#SysConfigSearch", "css" )->send_keys('LoginURL');
        $Selenium->WaitFor(
            JavaScript => 'return typeof($) === "function" && !$("#AJAXLoaderSysConfigSearch:visible").length;'
        );
        $Selenium->WaitFor( JavaScript => 'return typeof($) === "function" && $("li.ui-menu-item:visible").length;' );
        $Selenium->find_element( "#SysConfigSearch", "css" )->VerifiedSubmit();
        $Selenium->WaitFor(
            JavaScript => 'return typeof($) === "function" && $(".fa-exclamation-triangle").length;',
        );

        my $Message = $Selenium->find_element( ".fa-exclamation-triangle", "css" )->get_attribute('title');
        $LogObject->Dumper( '$Message', $Message );
        $Self->Is(
            'Changing this setting is only available in a higher config level!',
            $Message,
            "Check if setting restriction message is present."
        );

        # Navigate to AdminSysConfig screen.
        $Selenium->VerifiedGet(
            "${ScriptAlias}index.pl?Action=AdminSystemConfigurationGroup;RootNavigation=Frontend::Agent::View::TicketQueue"
        );

        # Wait until page is loaded with jstree content in sidebar.
        $Selenium->WaitFor(
            JavaScript =>
                'return typeof($) === "function" && $(".fa-exclamation-triangle").length && $("#ConfigTree > ul:visible").length;',
        );

        $Message = $Selenium->find_element( ".fa-exclamation-triangle", "css" )->get_attribute('title');
        $Self->Is(
            'Changing this setting is only available in a higher config level!',
            $Message,
            "Check if setting restriction message is present."
        );
    }
);

1;