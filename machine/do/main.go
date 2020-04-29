package main

import (
	"fmt"

	do "github.com/pulumi/pulumi-digitalocean/sdk/go/digitalocean"
	"github.com/pulumi/pulumi/sdk/v2/go/pulumi"
	"github.com/spf13/viper"
)

func readConfig() error {
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")

	if err := viper.ReadInConfig(); err != nil {
		return fmt.Errorf("failed to read config: %v", err)
	}
	return nil
}

func main() {
	if err := readConfig(); err != nil {
		panic(err)
	}

	dropletName := viper.GetString("name")

	// Create droplet args.
	droplet := &do.DropletArgs{
		Image:   pulumi.String(viper.GetString("image")),
		Region:  pulumi.String(viper.GetString("region")),
		Size:    pulumi.String(viper.GetString("size")),
		SshKeys: pulumi.StringArray{},
	}

	// Read ssh key IDs from the config file.
	sshkeys := pulumi.StringArray{}
	keyIDs := viper.GetStringSlice("sshKeys")
	for _, id := range keyIDs {
		sshkeys = append(sshkeys, pulumi.String(id))
	}
	droplet.SshKeys = sshkeys

	pulumi.Run(func(ctx *pulumi.Context) error {
		// Image:  pulumi.String("ubuntu-18-04-x64"),
		droplet, err := do.NewDroplet(ctx, dropletName, droplet)
		if err != nil {
			return err
		}

		ctx.Export("name", droplet.Name)
		ctx.Export("ip", droplet.Ipv4Address)

		return nil
	})
}
