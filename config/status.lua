return {
    zh = {
        -- 系统状态码
        [0x000000] = 'ok',
        [0x000001] = '验证错误',
        [0x000002] = '数据不存在',
        [0x000003] = '密码错误',
        [0x000004] = '未授权访问',
        [0x000005] = '系统错误，数据库错误',
        [0x000006] = '请求太频繁，请稍后访问',
        [0x000007] = '系统错误，系统数据异常',
        [0x000008] = '系统错误，共享内存错误',
        [0x000009] = '系统错误，发起 Http 请求错误',
        [0x00000A] = '系统错误, Cookie 错误',
        [0x00000B] = '系统错误，定时器错误',
        [0x00000C] = '系统异常，用户未登录',

        -- user module
        [0x010001] = '注册失败，手机号已存在',
        [0x010002] = '登录失败，手机号或密码错误',
        [0x010003] = '登录失败，用户不存在',
        [0x010004] = '短信验证失败，短信验证码错误',
        [0x010005] = '重置密码失败，旧密码错误',
        [0x010006] = '重置密码失败，系统异常',
        [0x010007] = '重置密码失败，新密码不能和旧密码相同',
        [0x010008] = '获取用户信息失败，系统错误',
        [0x010009] = '获取用户信息失败，用户不存在',

        -- notify module
        [0x020001] = '发送短信验证码失败，请在60秒之后重试',

        -- post module
        [0x030001] = '获取文章信息失败，文章不存在',
        [0x030002] = '更新文章失败，你不是文章作者',
        [0x030003] = '获取文章标签失败，标签不存在',

        -- comment module
        [0x040002] = '发布评论失败，关联文章不存在',

        -- oauth module
        [0x050001] = 'github 授权失败，请返回 http://lua-china.com/login 重新操作',
        [0x050002] = 'github 授权失败，系统错误，请返回 http://lua-china.com/login 重新操作'
    },
    en = {
        -- system code    
        [0x000000] = 'ok',
        [0x000001] = 'validate error',
        [0x000002] = 'data not found',
        [0x000003] = 'password error',
        [0x000004] = 'no authorization',
        [0x000005] = 'database error',
        [0x000006] = 'request frequency please be gentle',
        [0x000007] = 'system error,data cache error',
        [0x000008] = 'shared memory error',
        [0x000009] = 'http request err',
        [0x00000A] = 'system error, cookie error',
        [0x00000B] = 'system error, timer error',
        [0x00000C] = 'system error，user not authenticat',

        -- user module
        [0x010001] = 'phone number already exits',
        [0x010002] = 'phone no or password error',
        [0x010003] = 'user not exits',
        [0x010004] = 'SMS verification failed, SMS code error',
        [0x010005] = 'fail to reset password, old password error',
        [0x010006] = 'fail to reset password, unknow error',
        [0x010007] = 'fail to reset password, new password cannot equal to old password',
        [0x010008] = 'fail to get user info, system error',

        -- notify module
        [0x020001] = 'Fail to send SMS, please try again after 60 secs',
    }
}
