fn hash(bytes: &[u8]) -> u8 {
    let mut result = 0u8;
    for byte in bytes {
        result = byte.wrapping_add(result)
            .wrapping_mul(17);
    }
    return result;
}

pub fn f(s: &str) -> u32 {
    let mut result = 0u32;
    for part in s.split(',') {
        result += hash(part.as_bytes()) as u32;
    }
    return result;
}
