export class ResBasicModel<T> {
  errorCode: number;
  errorMsg: string;
  data: T;
  constructor(errorCode: number, errorMsg: string, data: T) {
    this.errorCode = errorCode;
    this.errorMsg = errorMsg;
    this.data = data;
  }
}