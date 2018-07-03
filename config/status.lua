return {
    -- system code    
	[0x000000] = 'ok',
    [0x000001] = 'validate error',
    [0x000002] = 'data not found',
    [0x000003] = 'password error',
    [0x000004] = 'no authorization',
    [0x000005] = 'database error',
    [0x000006] = 'request frequency please be gentle',
    [0x000007] = 'redis error',
    [0x000008] = 'shared memory error',
    [0x000009] = 'http request err',
    [0x00000A] = 'system set cookie error',
    [0x00000B] = 'failed to create the timer ',

    -- user module
    [0x010001] = 'phone number already exits',
    [0x010002] = 'phone no or password error',
    [0x010003] = 'user not exits',
    [0x010004] = 'sms code error',
    [0x010005] = 'reset password fail, old password error',
    [0x010006] = 'reset password fail, unknow error',
    [0x010007] = 'reset password fail, new password cannot equal to old password',
    [0x010008] = 'get user info fail, system error',

    -- notify module
    [0x020001] = 'send sms fail, you can only send once ervey 60 secs'
}
