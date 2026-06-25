package config

// ServerConfig 服务器配置
type ServerConfig struct {
	Port string
}

// DefaultConfig 返回默认配置
func DefaultConfig() *ServerConfig {
	return &ServerConfig{
		Port: "8899",
	}
}
