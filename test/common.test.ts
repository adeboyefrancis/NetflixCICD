import {
  formatBytes,
  formatTime,
  formatMinuteToReadable,
  getRandomNumber,
} from 'src/utils/common';

describe('common util helpers', () => {
  test('getRandomNumber returns number less than max', () => {
    const max = 10;
    const n = getRandomNumber(max);
    expect(n).toBeGreaterThanOrEqual(0);
    expect(n).toBeLessThan(max);
  });

  test('formatMinuteToReadable handles hours and minutes', () => {
    expect(formatMinuteToReadable(125)).toBe('2h 5m');
    expect(formatMinuteToReadable(45)).toBe('45m');
  });

  test('formatBytes converts bytes to human readable', () => {
    expect(formatBytes(0)).toBe('0 Bytes');
    expect(formatBytes(1024)).toBe('1 KiB');
    expect(formatBytes(1048576)).toBe('1 MiB');
  });

  test('formatTime outputs hh:mm:ss or mm:ss', () => {
    expect(formatTime(5)).toBe('00:05');
    expect(formatTime(65)).toBe('01:05');
    expect(formatTime(3665)).toBe('01:01:05');
  });
});
