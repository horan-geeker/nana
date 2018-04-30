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

    -- notify module
    [0x020001] = 'code not expire'
}
