// ignore_for_file: constant_identifier_names

import 'dart:io';

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

// localhost
const emulatorIp = 'http://10.0.2.2:8080/api';
const simulatorIp = 'http://127.0.0.1:8080/api';

final ip = Platform.isIOS ? simulatorIp : emulatorIp;
