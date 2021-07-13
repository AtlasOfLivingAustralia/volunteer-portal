package au.org.ala.volunteer

class PrettySize {

    public static final BigInteger ONE_KB = BigInteger.valueOf(1024)
    public static final BigInteger ONE_MB = ONE_KB.multiply(ONE_KB)
    public static final BigInteger ONE_GB = ONE_KB.multiply(ONE_MB)
    public static final BigInteger ONE_TB = ONE_KB.multiply(ONE_GB)
    public static final BigInteger ONE_PB = ONE_KB.multiply(ONE_TB)
    public static final BigInteger ONE_EB = ONE_KB.multiply(ONE_PB)
    public static final BigInteger ONE_ZB = ONE_KB.multiply(ONE_EB)
    public static final BigInteger ONE_YB = ONE_KB.multiply(ONE_ZB)

    static String toPrettySize(final long size) {
        return toPrettySize(BigInteger.valueOf(size))
    }

    static String toPrettySize(BigInteger size) {
        String displaySize
        BigDecimal decimalSize = new BigDecimal(size)

        if (size.divide(ONE_YB).compareTo(BigInteger.ZERO) > 0) {
            displaySize = String.valueOf(size.divide(ONE_YB)) + " YB"
        } else if (size.divide(ONE_ZB).compareTo(BigInteger.ZERO) > 0) {
            displaySize = getThreeSigFigs(decimalSize.divide(new BigDecimal(ONE_ZB))) + " ZB"
        } else if (size.divide(ONE_EB).compareTo(BigInteger.ZERO) > 0) {
            displaySize = getThreeSigFigs(decimalSize.divide(new BigDecimal(ONE_EB))) + " EB"
        } else if (size.divide(ONE_PB).compareTo(BigInteger.ZERO) > 0) {
            displaySize = getThreeSigFigs(decimalSize.divide(new BigDecimal(ONE_PB))) + " PB"
        } else if (size.divide(ONE_TB).compareTo(BigInteger.ZERO) > 0) {
            displaySize = getThreeSigFigs(decimalSize.divide(new BigDecimal(ONE_TB))) + " TB"
        } else if (size.divide(ONE_GB).compareTo(BigInteger.ZERO) > 0) {
            displaySize = getThreeSigFigs(decimalSize.divide(new BigDecimal(ONE_GB))) + " GB"
        } else if (size.divide(ONE_MB).compareTo(BigInteger.ZERO) > 0) {
            displaySize = getThreeSigFigs(decimalSize.divide(new BigDecimal(ONE_MB))) + " MB"
        } else if (size.divide(ONE_KB).compareTo(BigInteger.ZERO) > 0) {
            displaySize = getThreeSigFigs(decimalSize.divide(new BigDecimal(ONE_KB))) + " KB"
        } else {
            displaySize = String.valueOf(size) + " bytes"
        }
        return displaySize
    }

    private static String getThreeSigFigs(BigDecimal displaySize) {
        String number = String.valueOf(displaySize)
        StringBuffer trimmedNumber = new StringBuffer()
        int cnt = 0
        for (char digit : number.toCharArray()) {
            if (cnt < 3) {
                trimmedNumber.append(digit)
            }
            if (digit != ('.' as char)) {
                cnt++
            }
        }
        return trimmedNumber.toString()
    }

}
