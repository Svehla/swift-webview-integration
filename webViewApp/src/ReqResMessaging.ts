// ------------------------------------------
//     LOW-LEVEL Messaging Protocol specs
// ------------------------------------------


// TODO: what about to use uuid4?
// https://stackoverflow.com/a/53723395/8995887
const generateId = () => `id-${Date.now().toString(36)}-${Math.random().toString(36).slice(2)}}`

const DirectionFlow = {
  REQUEST: 'REQUEST',
  RESPONSE: 'RESPONSE' ,
  ERROR_RESPONSE: 'ERROR_RESPONSE' ,
} as const

const build = {
  request: <U extends JSONDictionary>(uri: string, body?: U) => ({
    id: generateId(),
    directionFlow: DirectionFlow.REQUEST,
    uri,
    body,
  }),

  response: <U extends JSONDictionary>(id: string, data?: U) => ({
    id,
    directionFlow: DirectionFlow.RESPONSE,
    data,
  }),

  errorResponse: (id: string, error?: string) => ({
    id,
    directionFlow: DirectionFlow.ERROR_RESPONSE,
    error
  }),
}

type MessageType = ReturnType<typeof build[keyof typeof build]>
type JSONDictionary = any

type MessageHandlerCb = (body: JSONDictionary) => JSONDictionary

type PendingState = {
  uri: string
  cleanUp: () => void,
  resolve: (...args: any[]) => void
  reject: (...args: any[]) => void
}

// TODO: rewrite class into closures?
export class ReqResMessaging {

  _pendingRequests = {} as Record<string, PendingState>

  _emitMessage: undefined | ((message: MessageType) => any)

  _messageHandlers = {} as Record<string, (body: any) => any>


  // TODO: what about to move this into the constructor?
  registerEmitMessage(emitMessage: (message: MessageType) => void) {
    this._emitMessage = emitMessage
  }

  removeOnMessage(uri: string) {
    delete this._messageHandlers[uri]
  }

  onMessage(uri: string, messageHandlerCb: MessageHandlerCb) {
    if (this._messageHandlers[uri]) {
      throw new Error(`message handler for '${uri}' is already defined`)
    }
    this._messageHandlers[uri] = messageHandlerCb
  }

  handleMessage = async (message: MessageType) => {
    if (!this._emitMessage) throw new Error("Emit message is not defined")
    const id = message.id
    if (!id) throw new Error(`invalid message id: ${JSON.stringify(message)}`)
    const directionFlow = message.directionFlow
    if (!directionFlow) throw new Error(`invalid message id: ${JSON.stringify(message)}`)


    switch (message.directionFlow) {
  
      case DirectionFlow.REQUEST: {
        let uri = message.uri
        if (!uri) return
        let body = message.body
        if (!body) return
        const messageHandler = this._messageHandlers[uri]
        if (!messageHandler) {
          this._emitMessage(build.errorResponse(id, `message handler ${uri} does not exist`))
          return
        }

        let messageToSend
        try {
          const data = await messageHandler(body)
          
          messageToSend = build.response(id, data)
        } catch(err) {
          messageToSend = build.errorResponse(id, `${err}`)
        }

        this._emitMessage(messageToSend)
        break;
      }

      case DirectionFlow.RESPONSE: {
        const request = this._pendingRequests[id];
        if (!request) return;
        const data = message.data
        request.cleanUp();
        request.resolve(data);
        break;
      }

      case DirectionFlow.ERROR_RESPONSE: {
        const request = this._pendingRequests[id];
        if (!request) return;
        const resError = message.error
        // empty string is valid error message...
        if (resError === undefined) return;
        request.cleanUp();
        request.reject(new Error(resError));
        break;
      }

      default: 
        console.log(`unsupported directionFlow: ${(message as any)?.directionFlow} handler for message: ${message}`)
  
    }
  };

  fetchMessage = <Body, Response>(
    uri: string,
    body: Body,
  ) => {
    if (!this._emitMessage) throw new Error("Emit message is not defined")
    return new Promise<Response>((resolve, reject) => {
  
      const request = build.request(uri, body)
  
      this._pendingRequests[request.id] = {
        uri: request.uri,
        cleanUp: () => delete this._pendingRequests[request.id],
        resolve,
        reject
      };

      this._emitMessage!(request)
    });
  }
}

