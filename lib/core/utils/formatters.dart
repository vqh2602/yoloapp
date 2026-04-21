String formatPercent(double value) => '${(value * 100).toStringAsFixed(1)}%';

String compactPath(String value) {
  if (value.length <= 48) {
    return value;
  }

  return '${value.substring(0, 22)}...${value.substring(value.length - 20)}';
}
