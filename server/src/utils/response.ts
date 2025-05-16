export class ApiResponse {
  static success(data: any, message: string = 'Success') {
    return {
      status: 'success',
      message,
      data,
      timestamp: new Date().toISOString()
    };
  }

  static error(message: string, statusCode: number = 500, errors: any = null) {
    return {
      status: 'error',
      message,
      statusCode,
      errors,
      timestamp: new Date().toISOString()
    };
  }
}

export default ApiResponse;
