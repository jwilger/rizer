pub fn hello() -> &'static str {
    "Hello, world!"
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_hello() {
        assert_ne!(hello(), "");
    }
}
