import axios from 'axios'
import applyCaseMiddleware from 'axios-case-converter'

export interface OnlyResultCodeResponse {
  ok: number
}

interface GetOauthResponse{
    url: string
}

interface PostOauthRequest{
    code: string
}

function getApiUrl() {
  return 'http://localhost:3001/api/v1/'
}

export class ApiClient {
  private instance = applyCaseMiddleware(
    axios.create({
      baseURL: getApiUrl(),
      timeout: 10000,
      withCredentials: true
    })
  )

  public getUrl() {
    return this.instance.get<GetOauthResponse>('oauth')
  }

  public postOauth(payload: PostOauthRequest) {
    return this.instance.post<OnlyResultCodeResponse>('oauth', payload)
  }
}
