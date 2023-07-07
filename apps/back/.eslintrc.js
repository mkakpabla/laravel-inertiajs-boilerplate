require("@rushstack/eslint-patch/modern-module-resolution")
const path = require('node:path')
const createAliasSetting = require('@vue/eslint-config-airbnb/createAliasSetting')

module.exports = {
    extends: [
        'plugin:vue/vue3-recommended',
        'airbnb-base'
    ],

    settings: {
        ...createAliasSetting({
            '@': `${path.resolve(__dirname, './resources/js')}`
        })
    }

}
