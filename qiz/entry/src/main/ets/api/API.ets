import { get, post } from '../utils/HttpUtil'
import http from '@ohos.net.http'
import UserModel from '../model/UserModel'
import RecordModel from '../model/RecordModel'

export const captcha  = ():Promise<http.HttpResponse> =>get("/api/captcha")

export const reg = (params:UserModel):Promise<http.HttpResponse> =>post("/user/reg",params)

export const login = (params:UserModel):Promise<http.HttpResponse> =>post("/user/login",params)

export const question  = (page:number):Promise<http.HttpResponse> =>get(`/api/question?page=${page}`)

export const user  = (token:string):Promise<http.HttpResponse> =>get(`/user/data?token=${token}`)

export const record  = (params:RecordModel):Promise<http.HttpResponse> =>post('/api/question/answer',params)

export const fetchUsers  = ():Promise<http.HttpResponse> =>get("/api/users")