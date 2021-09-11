Describe 'With Utilities Tests' {
    
    BeforeAll {
        Set-Location $PSScriptRoot
        Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
    }

    BeforeEach {
        Reset-Workflow
    }

    It 'Encrypt and Decrypt Secret' {
        $seed = 'aLong1%Seed'
        $secretValue = 'aSecret'

        $secret = Get-EncryptedSecret -Value $secretValue -Seed $seed
        $secretValue2 = Get-DecryptedSecret -Value $secret -Seed $seed
        Assert-Condition -Value $secret -o '-ne' -Value2 $secretValue -Message 'Validate Secret'
        Assert-Condition -Actual $secretValue2 -Expected $secretValue -Message 'Validate SecretValue'
    }

}
