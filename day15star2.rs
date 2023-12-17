fn hash(bytes: &[u8]) -> u8 {
    let mut result = 0u8;
    for byte in bytes {
        result = byte.wrapping_add(result)
            .wrapping_mul(17);
    }
    return result;
}

pub fn f(s: &str) -> usize {
    const EMPTY_VEC: Vec<(&str, u8)> = Vec::new();
    let mut boxes: [Vec<(&str, u8)>; 256] = [EMPTY_VEC; 256];
    for part in s.split(',') {
        if part.contains('=') {
            if let [name, focal_dist_str] = part.split('=').collect::<Vec<_>>().as_slice() {
                let focal_dist = focal_dist_str.parse::<u8>().unwrap();
                let curr_box = &mut boxes[hash(name.as_bytes()) as usize];
                if let Some(i) = curr_box.iter().position(|t| &t.0 == name) {
                    curr_box[i].1 = focal_dist;
                } else {
                    curr_box.push((name, focal_dist));
                }
            } else {
                unreachable!();
            }
        } else {
            let name = part.strip_suffix("-").unwrap();
            let curr_box = &mut boxes[hash(name.as_bytes()) as usize];
            if let Some(i) = curr_box.iter().position(|t| t.0 == name) {
                curr_box.remove(i);
            }
        }
    }

    let mut result = 0usize;
    for (i, v) in boxes.iter().enumerate() {
        for (j, t) in v.iter().enumerate() {
            result += (i + 1) * (j + 1) * (t.1 as usize);
        }
    }
    return result;
}
